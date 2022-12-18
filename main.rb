# Prereqs:
# gem install nokogiri

require 'nokogiri'

OUTPUT_FILE_PATH = "./output.md"
CHAPTER_TITLE_HIGHLIGHT_REGEX = /^(Highlight).* - ((?<chapter_title>.*) > )* (Page|Location) (?<number>.*)/
CHAPTER_TITLE_NOTE_REGEX = /^(Note) - ((?<chapter_title>.*) > )* (Page|Location) (?<number>.*)/

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
    last_was_note = false
    last_note_number = 0

    divs.each do |div|
      div_class = div["class"]
      div_text = div.text.strip

      case div_class
      when "sectionHeading"
        output_string += "# #{div_text}\n\n"
      when "noteHeading"
        highlight_match = div_text.match(CHAPTER_TITLE_HIGHLIGHT_REGEX)
        note_match = div_text.match(CHAPTER_TITLE_NOTE_REGEX)

        if !highlight_match.nil?
          last_was_note = false

          chapter_title = highlight_match[:chapter_title]
        elsif !note_match.nil?
          last_was_note = true
          last_note_number = note_match[:number]

          chapter_title = note_match[:chapter_title]
        else
          puts "Error: not matched. Text: #{div_text}"
          return
        end

        if chapter_title != last_heading && !chapter_title.nil?
          output_string += "## #{chapter_title}\n\n"
          last_heading = chapter_title
        end
      when "noteText"
        if last_was_note
          output_string += "NOTE @#{last_note_number}: #{div_text}\n\n"
        else
          output_string += "#{div_text}\n\n"
        end
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
