module vrepl;

import std.stdio: write, writeln;
import std.conv: to;

class Vrepl {
		string promptStr = ">";

		this() {}

		void setPrompt(in char[] p) {
				this.promptStr = p.to!string;
		}

		void prompt() {
				write(promptStr ~ " ");
		}

		void quit() {
		}

		bool isQuit(in char[] line) {
				return line == "quit" || line == "bye" || line == "exit";
		}
		void loop() {
				import std.string: chomp;
				import std.stdio: stdin, readln;
				string line;
				prompt();
				while ((line = stdin.readln) !is null) {
						line = line.chomp;
						if (isQuit(line)) {
								return;
						}
						writeln("your wrote:", line);
						prompt();
				}
				quit();
		}
}

