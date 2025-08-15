require 'json'

module Topics
  class Generator < Jekyll::Generator
    def generate(site)
      stdout, stderr, status = Open3.capture3("python %s/_plugins/topics.py" % site.source)
      puts stderr
      site.data["topics"] = JSON.parse(stdout)
    end
  end
end
