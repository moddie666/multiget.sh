# multiget.sh
wget multiple files at the same time from sites like archive.org

```
:~$ multiget.sh -h
MultiGET
Download multiple large files with specific extensions in parallel from a site
offering files for download via http(s). For example archive.org.
USAGE: multiget.sh [-c|-t] <EXT> <URL(s)>
-w <num> ... number of concurrent wget processes
      -c ... clear screen before each status update.
      -t ... show what would be downloaded, but don't do anything.
     EXT ... extension(s) to download (case insensitive).
             Examples: single: '\.iso' multiple: '\.bin|\.cue'
  URL(s) ... URL (folder) where the files reside.
```
