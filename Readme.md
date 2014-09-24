# em-zipstream

First, dirty, draft of streaming archives using EventMachine. It does work though and *relatively* well.

### Main problem points

* No back pressure management.

  https://groups.google.com/forum/#!msg/eventmachine/W8UIWs_lAXU/-GFxb6OYFuUJ

* Header issues that cause zips to be unexpandable on Windows OS 

  Zip files can be explored, but not expanded. And, of course it only happens on Windows. No other OS encounters this issue.

## Note

Very old project.

## License

MIT
