# Prereqs:
# gem install nokogiri

require 'nokogiri'

OUTPUT_FILE_PATH = "./output.md"
CHAPTER_TITLE_REGEX = /^Highlight.* - ((?<chapter_title>.*) > )* Page (?<number>.*)/

# Main
def usage
"""
Parses Kindle exported highlights into a markdown file. Defaults output to #{OUTPUT_FILE_PATH}

Usage: ruby main.rb <input_file_path>
"""
end

def main
  input_file = ARGV[0]
  if input_file.nil?
    puts usage
    exit
  end

  output_string = ""

  File.open(input_file, "r") do |input_file|
    html_content = input_file.read
    document = Nokogiri::HTML.parse(html_content)
    divs = document.css("div.bodyContainer div")

    last_heading = ""

    divs.each do |div|
      div_class = div["class"]
      div_text = div.text.strip

      case div_class
      when "sectionHeading"
        output_string += "# #{div_text}\n\n"
      when "noteHeading"
        chapter_title = div_text.match(CHAPTER_TITLE_REGEX)[:chapter_title]

        if chapter_title != last_heading && !chapter_title.nil?
          output_string += "## #{chapter_title}\n\n"
          last_heading = chapter_title
        end
      when "noteText"
        output_string += "#{div_text}\n\n"
      end
    end
  end

  File.open(OUTPUT_FILE_PATH, "w") do |output_file|
    output_file.write(output_string)
  end

  puts "Done! Output is in: #{OUTPUT_FILE_PATH}\n"
end

# Run the script
main()
