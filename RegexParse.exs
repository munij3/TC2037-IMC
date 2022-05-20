defmodule Regx do
  def get_lines(in_filename, out_filename) do
    expr =
      in_filename
      |> File.stream!()
      |> Enum.map(&token_from_line/1)
      |> Enum.filter(&(&1 != nil))
      #|> Enum.map(&hd/1)

    File.write(out_filename, expr)
  end


  def token_from_line(line) do
    token_from_line(line,"",false,true)
  end

  def token_from_line(line, html_string, aftr,bftr) do
    #IO.inspect(bftr)
    #IO.inspect(line)
      cond do

    Regex.match?(~r/\s*[{}\[\]\(\)]\s*"\N*"\s*:/,line) and bftr ->
      [_string, token] = Regex.run(~r/(\s*[[:punct:]]\s*)/,line)
      [_h | t] = String.split(line, ~r/(\s*[[:punct:]]\s*)/, parts: 2)
      tmp = "#{html_string}<span class='punctuation'>#{token}</span>"
      aftr = false
      [tail] = t
      #IO.inspect(line)
      html_string = tmp
      token_from_line(tail,html_string,aftr,false)


      (Regex.match?(~r/\s*"\N*"\s*\:\s*"\N*"\s*,\s*"\N*"\s*\:/,line)) ->
        [_string, token] = Regex.run(~r/(\s*"\N*"\s*)\:\s*"\N*"\s*,\s*"\N*"\s*\:/,line)
        [_string2, token2] = Regex.run(~r/\s*"\N*"\s*\:(\s*"\N*"\s*),\s*"\N*"\s*\:/,line)
        [_string3, token3] = Regex.run(~r/(,)/,line)
        [_h | t] = String.split(line, ~r/(\s*"\N*"\s*\:\s"\N*"\s*,)/, parts: 2)
        tmp = "#{html_string}<span class='object-key'>#{token}</span><span class='dot'>:</span><span class='string'>#{token2}</span><span class='punctuation'>#{token3}</span>"
        [tail] = t
        IO.inspect("#{line} ||| #{tail} ||| #{token3}")
        html_string = tmp
        aftr = true
        token_from_line(tail,html_string,aftr,false)

        (Regex.match?(~r/\s*"\N*"\s*\:/,line)) ->
          [_string, token] = Regex.run(~r/(\s*"\N*"\s*):/,line)
          [_h | t] = String.split(line, ~r/(\s*"\N*"\s*\:)/, parts: 2)
          tmp = "#{html_string}<span class='object-key'>#{token}</span><span class='dot'>:</span>"
          [tail] = t
          IO.inspect("#{line} ||| #{tail} ||| #{token}")
          html_string = tmp
          aftr = true
          token_from_line(tail,html_string,aftr,false)

       (Regex.match?(~r/\s*[,\]\[{}]\s*"\N*"\s*/,line) and aftr) ->
          [_string, token] = Regex.run(~r/(\s*[,\]\[{}]\s*)/, line)
          [_h | t] = String.split(line, ~r/\s*[,\]\[{}]\s*/, parts: 2)
          tmp = "#{html_string}<span class='punctuation'>#{token}</span>"
          aftr = false
          [tail] = t
          html_string = tmp
          token_from_line(tail,html_string,aftr,false)


        (Regex.match?(~r/\s*"\N*"\s*/,line)) ->
            [_string, token] = Regex.run(~r/(\s*"\N*"\s*)/,line)
            [_h | t] = String.split(line, ~r/(\s*"\N*"\s*)/,  parts: 2 )
            tmp = "#{html_string}<span class='string'>#{token}</span>"
            aftr = true
            [tail] = t
            html_string = tmp

            token_from_line(tail,html_string,aftr,false)


        Regex.match?(~r/\s*\d+\.?\d*E?[+|-]?\d*\s*/,line) ->
            [_string, token] = Regex.run(~r/(\s*\d+\.?\d*E?[+|-]?\d*\s*)/,line)
            [_h | t] = String.split(line, ~r/(\s*\d+\.?\d*E?[+|-]?\d*\s*)/,  parts: 2)
            tmp = "#{html_string}<span class='number'>#{token}</span>"
            #IO.inspect(token)
            [tail] = t
            aftr = false
            html_string = tmp
            token_from_line(tail,html_string,aftr,false)


        Regex.match?(~r/\s*null|\s*true|\s*false\s*/,line) ->
            [_string, token] = Regex.run(~r/(\s*null|\s*true|\s*false\s*)/,line)
            [_h | t] = String.split(line, ~r/(\s*null|\s*true|\s*false\s*)/, parts: 2)
            tmp = "#{html_string}<span class='number'>#{token}</span>"
            [tail] = t
            #IO.inspect(token)
            aftr = false
            html_string = tmp
            token_from_line(tail,html_string,aftr,false)

        Regex.match?(~r/\s*[[:punct:]]\s*/,line) ->
            [_string, token] = Regex.run(~r/(\s*[[:punct:]]\s*)/,line)
            [_h | t] = String.split(line, ~r/(\s*[[:punct:]]\s*)/, parts: 2)
            tmp = "#{html_string}<span class='punctuation'>#{token}</span>"
            aftr = false
            [tail] = t
            html_string = tmp
            token_from_line(tail,html_string,aftr,false)



        true ->
          html_string

      end
  end
end

Regx.get_lines("./Test_Files/example_5.json", "test.html")
