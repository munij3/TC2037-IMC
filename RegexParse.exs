defmodule Regx do
  def get_lines(in_filename, out_filename) do
    expr =
      in_filename
      |> File.stream!()
      |> Enum.map(&token_from_line/1)
      |> Enum.filter(&(&1 != nil))
      #|> Enum.map(&hd/1)
      |> Enum.join("\n")
    File.write(out_filename, expr)
  end

  def token_from_line(line) do
    token_from_line(line,"",false)
  end

  def token_from_line(line, html_string, aftr) do
      cond do

        (Regex.match?(~r/\s*("\w+")\s*/,line) and !aftr) ->
          [_string, token] = Regex.run(~r/\s*("\w+")\s*/,line)
          [_h | t] = String.split(line, ~r/\s*("\w+")\s*/, parts: 2)
          tmp = "#{html_string}<span class='object-key'>#{token}</span>"
          [tail] = t
          html_string = tmp
          IO.inspect(tail)
          token_from_line(tail,html_string,aftr)

        (Regex.match?(~r/\s*("[\s*\w*\:*\.*]*")\s*/,line) and aftr == true) ->
          [_string, token] = Regex.run(~r/\s*("[\s*\w*\:*\.*]*")\s*/,line)
          [_h | t] = String.split(line, ~r/\s*("[\s*\w*\:*\.*]*")\s*/, parts: 2)
          tmp = "#{html_string}<span class='string'>#{token}</span>"
          aftr = false
          [tail] = t
          html_string = tmp
          token_from_line(tail,html_string,aftr)

        Regex.match?(~r/\s*(:)\s*/,line) ->
          [_string, token] = Regex.run(~r/\s*(:)\s*/,line)
          [_h | t] = String.split(line, ~r/\s*(:)\s*/, parts: 2)
          tmp = "#{html_string}<span class='dot'>#{token}</span>"
          [tail] = t
          html_string = tmp
          aftr = true
          token_from_line(tail,html_string,aftr)

        Regex.match?(~r/(\d+.?\d*E?[+|-]?\d*)/,line) ->
          [_string, token] = Regex.run(~r/(\d+.?\d*E?[+|-]?\d*)/,line)
          [_h | t] = Regex.split(~r/(\d+.?\d*E?[+|-]?\d*)/, line, parts: 2)
          tmp = "#{html_string}<span class='number'>#{token}</span>"
          [tail] = t
          aftr = false
          html_string = tmp
          token_from_line(tail,html_string,aftr)

        Regex.match?(~r/\s*null|true|false\s*/,line) ->
          [_string, token] = Regex.run(~r/\s*(null|true|false)\s*/,line)
          [_h | t] = Regex.split(~r/\s*(null|true|false)\s*/, line, parts: 2)
          tmp = "#{html_string}<span class='number'>#{token}</span>"
          [tail] = t
          aftr = false
          html_string = tmp
          token_from_line(tail,html_string,aftr)

        Regex.match?(~r/\s*[,\[\]\{\}]\s*/,line) ->
          [_string, token] = Regex.run(~r/\s*([,}{\[ \]])\s*/,line)
          [_h | t] = Regex.split(~r/\s*([,}{\[ \]])\s*/, line, parts: 2)
          tmp = "#{html_string}<span class='punctuation'>#{token}</span>"
          [tail] = t
          aftr = false
          html_string = tmp
          token_from_line(tail,html_string,aftr)




        true ->
          html_string
      end
  end
end

Regx.get_lines("./Test_Files/example_0.json", "test.html")
