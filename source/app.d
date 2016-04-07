import std.stdio;
import std.string: chomp;
import std.conv: to;

void main()
{
				write("> ");
				string line;
				while ((line = stdin.readln) !is null) {
						line = line.chomp;
						if (line == "quit" || line == "bye") {
								return;
						}
						writeln("your wrote:", line);
						writeln("> ");
				}
				writeln();
}
