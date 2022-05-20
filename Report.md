# Report


## The program
In order to create this regex parser for json files, we decided to define a set of regex expressions that would act as conditions for evaluating ourt file stream. By this, when our program effectively matches a regex expression, a token representing the matched object will be set within an html expression, with its specified expression category (be it punctuation, an object key, a number, a string, or a boolean value.)

```elixir
    (Regex.match?(~r/\s*\d+\.?\d*E?[+|-]?\d*\s*/,line)) ->
        [_string, token] = Regex.run(~r/(\s*\d+\.?\d*E?[+|-]?\d*\s*)/,line)
        [_h | t] = String.split(line, ~r/(\s*\d+\.?\d*E?[+|-]?\d*\s*)/,  parts: 2)
        tmp = "#{html_string}<span class='number'>#{token}</span>"
        html_string = tmp
```
<em>(Regex match for digit expressions, be it regular integers, floating point numbers, or exponential numbers)</em>

As seen in the exaple above, our code effectively ignores each match head, obtaining the token as the match tail with the regex expression within the parentheses. As for the String.split, matched values whitch are space separated values will be returned as head and tail, the latter being the next line to evaluate recursively.

After the regex match, by evaluating true, the assigned html string will be returned, and then concatenated with the rest of the generated strings.

## Complexity

The program holds a time complexity of O(n) as the execution time depends on the length of the file stream. Our file uses a pipeline which always holds an O(n) time complexity by mapping the file stream and recursively operating it, filtering out nil values, and then generating the html document with the resulting string built with every recursive step.

```elixir
  def get_lines(in_filename, out_filename) do
    expr =
      in_filename
      |> File.stream!()
      |> Enum.map(&token_from_line/1)
      |> Enum.filter(&(&1 != nil))
    tmp = "<!DOCTYPE html>\n<html>\n\t<head>\n\t\t<title>JSON Code</title>\n\t\t<link rel='stylesheet' href='token_colors.css'>\n\t</head>\n\t<body>\n\t\t<h1>Date: #{DateTime.utc_now}</h1>\n\t\t<pre>\n\t\t\t#{expr}\n\t\t\t</pre>\n\t</body>\n</html>"
    expr = tmp
    File.write(out_filename, expr)
  end
```
(<em>Please don't mind our brute force solution for generating the html page.</em>)

By implementing tail recursion, space complexity is reduced to O(1) complexity as stack frames are disposed of in each step.

```elixir
  def token_from_line(line) do
    token_from_line(line,"",false,true)
  end
```

As for the code iteself, as seen in the regex example previously, every regex match/run operation has O(n) time complexity, as the match depends on the length of the line being evaluated. By pattern matching to obtain the regex match tail, time complexity still has O(n) compelxity, as a simple head | tail pattern match of the regex expression has O(1) compelxity. The same holds for Regex.split operations, as the same pattern match of the regex evaluation of a line occurs.

## Conclusion

We believe this approach can be very efficient in contrast to using, ie. String.replace method for generating the resulting html file, which would imply an O(n^2) complexity. By implementing tail recursion with purely linear and constant operations, our program execution time soley depends on the length of the file. This in turn let us extract tokens with ease by using pattern matching with the same expression.
