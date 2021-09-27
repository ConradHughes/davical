#!/usr/bin/perl

# Help diffing vcard collections by sorting and cleaning:
#
#   - Sorts supplied collection of vcards by full name (FN).
#   - Filters out keys that vary from one calendar to the next.

use Modern::Perl '2018';
use autodie ':all';
use open ':std', IO => ':crlf :encoding(UTF-8)';

$/ = "\n\n";
my %entries;
while(<>) {
  chomp $_;
  my ($key) = /^FN:(.*)$/m or die "No FN:\n$_";
  # These entries vary from calendar copy to calendar copy, so remove
  # them to make diffs cleaner.
  s/^(?:X-EVOLUTION-WEBDAV-ETAG|REV):.*\n//mg;
  die "Duplicate FN \"$key\".\n" if exists $entries{$key};
  $entries{$key} = $_;
}

print join("\n\n", @entries{sort keys %entries});
