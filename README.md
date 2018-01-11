# FSWatch

[![Build Status](https://travis-ci.org/WebFreak001/FSWatch.svg?branch=master)](https://travis-ci.org/WebFreak001/FSWatch) [![Dub version](https://img.shields.io/dub/v/fswatch.svg) ![Dub downloads](https://img.shields.io/dub/dt/fswatch.svg)](https://code.dlang.org/packages/fswatch)

A cross platform library simplifying watching for file changes using a non-blocking interface using the Win32 API, `inotify` or `std.file.dirEntries` as fallback.

## Comparison between implementations
|Platform|Watching Directory|Watching File|
|---|---|---|
|Windows|`ReadDirectoryChangesW` (very fast, accurate)|polling using `std.file.timeLastModified` and `std.file.exists` (fast, not accurate for quick write)|
|Linux|`inotify` (very fast, accurate)|`inotify` (very fast, accurate)|
|Other|polling using `std.file.dirEntries` (slow, not accurate)|polling using `std.file.timeLastModified` and `std.file.exists` (fast, not accurate for quick write)|

To force usage of the `std.file` polling implementation you can just add `version = FSWForcePoll;`

Don't do this unless you have a specific reason as you will lose speed and accuracy!

## Example

```d
void main()
{
	// Initializes a FileWatch instance to watch on `project1/` (first argument) recursively (second argument)
	auto watcher = FileWatch("project1/", true);
	while (true)
	{
		// This will fetch all queued events or an empty array if there are none
		foreach (event; watcher.getEvents())
		{
			// paths are relative to the watched directory in most cases
			if (event.path == "dub.json" || event.path == "dub.sdl")
			{
				if (event.type == FileChangeEventType.create)
				{
					// dub.json or dub.sdl got created
				}
				else if (event.type == FileChangeEventType.modify)
				{
					// dub.json or dub.sdl got modified
				}
				else if (event.type == FileChangeEventType.remove)
				{
					// dub.json or dub.sdl got deleted
				}
			}
			if (event.type == FileChangeEventType.rename)
			{
				// The file `event.path` has been removed to `event.newPath`
			}
			else if (event.type == FileChangeEventType.createSelf)
			{
				// the folder we are watching has been created
			}
			else if (event.type == FileChangeEventType.removeSelf)
			{
				// the folder we are watching has been deleted or renamed
			}
		}
		// ...
		myapp.handleInput();
		myapp.update();
		myapp.draw();
	}
}
```
