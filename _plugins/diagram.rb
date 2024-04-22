require 'nokogiri'

module Jekyll
    class Diagram < Liquid::Block
        PYTHON_CODE = "
from diagrams import Diagram, Cluster, Edge, setdiagram
import sys

graph_attr = {
    'fontsize': '45',
    'bgcolor': 'transparent',
    'layout': 'neato',
    'overlap': 'scale',
    'splines': 'line',
}

print = lambda *args: sys.stderr.write(' '.join([str(arg) for arg in args]) + '\\n')

d = Diagram(show=False, graph_attr=graph_attr)
setdiagram(d)

script = '''
%s
'''

exec(script, {
    'print': lambda *args: sys.stderr.write(' '.join([str(arg) for arg in args]) + '\\n'),
    'Diagram': Diagram,
    'Cluster': Cluster,
    'Edge': Edge,
})

print = __builtins__.print

print(d.dot.pipe(format='svg', encoding='utf-8'))

exit(0)
        "
        NAMESPACES = {
            "svg"=>"http://www.w3.org/2000/svg",
            "xlink"=>"http://www.w3.org/1999/xlink"
        }
        class IconData
            def initialize(source)
                @source = source
            end
            def write?()
                return true
            end
            def destination(site)
                return site + path()
            end
            def path()
                return "/icons/" + File.basename(source)
            end
            def write(site)
                FileUtils.mkdir_p(site + "/icons")
                FileUtils.cp(source(), destination(site))
            end
            def source()
                return @source
            end
        end
        def initialize(tag_name, markup, opts)
            super
        end
        def render(context)
            # Have to replace backslashes with tripple blackslashes, once so Ruby doesn't treat \n as a newline, and again so Python's exec doesn't do the same.
            stdout, stderr, status = Open3.capture3("python", :stdin_data=>PYTHON_CODE % [super.gsub("\\", "\\\\\\")])
            puts stderr
            if status.success?
                svg = Nokogiri::XML(stdout)
                svg.search("//svg:image", NAMESPACES).each do |img|
                    add_icon(context, img["xlink:href"])
                    img["xlink:href"] = "/icons/" + File.basename(img["xlink:href"]) 
                end
                return svg.to_s
            else
                puts "Python exited with code #{status.exitstatus}"
            end
        end
        def add_icon(context, source)
            context.registers[:site].static_files.each do |file|
                if file.is_a?(IconData) and file.source == source
                    return
                end
            end
            context.registers[:site].static_files.append(IconData.new(source))
        end
    end
end

Liquid::Template.register_tag("diagram", Jekyll::Diagram)