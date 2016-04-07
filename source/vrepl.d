module vrepl;

import std.stdio: write, writeln;
import std.conv: to;
import containers;

alias StringSet = HashSet!string;

class Config {
		string prompt;
		StringSet quits;
		void delegate(string) onInput;

		this() {
				prompt = ">";
				quits.insert("quit");
				quits.insert("bye");
				quits.insert("exit");
		}
}

class Vrepl {
		Config config;

		this() {
				config = new Config();
		}

		void prompt() {
				write(config.prompt ~ " ");
		}

		void quit() { }

		bool isQuit(string line) {
				return config.quits.contains(line);
		}

		void loop() {
				import std.string: chomp;
				import std.stdio: stdin, readln;
				string line;
				writeln("begin");
				prompt();
				while ((line = stdin.readln) !is null) {
						line = line.chomp;
						if (isQuit(line)) {
								return;
						}
						if (config.onInput != null) {
								config.onInput(line);
						} else {
								writeln("your wrote:", line);
						}
						prompt();
				}
				quit();
		}
}

