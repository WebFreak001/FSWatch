import std.stdio;
import std.format;
import std.getopt;
import core.thread;

import fswatch;

void main(string[] args)
{
	uint period = 100;
	auto commandLine = getopt(args, "period", "Time period (in msecs) to check for path changes", &period);
	if (commandLine.helpWanted || args.length < 2) {
		defaultGetoptPrinter(format("Usage: %s [options...] path", args[0]), commandLine.options);
		return;
	}
	string toWatch = args[1];
	auto watcher = FileWatch(toWatch);
	writefln("Watching %s", toWatch);
	while(true) {
		auto events = watcher.getEvents();
		foreach(event; events) {
			final switch(event.type) with (FileChangeEventType)
			{
				case createSelf:
					writefln("Observable path created");
					break;
				case removeSelf:
					writefln("Observable path deleted");
					break;
				case create:
					writefln("'%s' created", event.path);
					break;
				case remove:
					writefln("'%s' removed", event.path);
					break;
				case rename:
					writefln("'%s' renamed to '%s'", event.path, event.newPath);
					break;
				case modify:
					writefln("'%s' contents modified", event.path);
					break;
			}
		}
		Thread.sleep(period.msecs);
	}
}
