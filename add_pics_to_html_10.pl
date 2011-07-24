#!/usr/bin/env perl
# add_pics_to_html_10.pl
# copyright 2011, m. tornow and fsmithred
# lots of help by telemachus and dbbolton too
# license: GPL-3


#--------------------------------------------------#
# USE
use warnings;
use 5.012_003;
use autodie;
use File::Copy;
#--------------------------------------------------#



#--------------------------------------------------#
# VARIABLES - Change localhost to a real host name or IP number for public access.
my $work_dir = "$ENV{HOME}/public_html/gallery";
my $pictures_dir = "pictures";
my $thumbnails_dir = "thumbnails";
my $gallery_html = "gallery.html";
my $url = "http://localhost/$ENV{USER}/gallery";


chdir ("$work_dir/$pictures_dir");
my @picture_folders = glob("*");
chdir ("$work_dir/$thumbnails_dir");
my @thumbnail_folders = glob("*");
chdir ("$work_dir");

#--------------------------------------------------#



#--------------------------------------------------#
# First of all: make a BACKUP
if ( -f $gallery_html ) {
	copy("$work_dir/$gallery_html","$work_dir/$gallery_html.orig");
}
#--------------------------------------------------#



# OPEN  for WRITING
open(my $out, ">", "$work_dir/$gallery_html");
#--------------------------------------------------#



#--------------------------------------------------#
# WRITE  HEADER
my $header = << "EOF";
<!doctype html>
\n<html>
\n<head>
<title>Gallery</title>
<meta charset="utf-8">
<link rel="stylesheet" href="../../css/screen-index.css">
\n</head>

\n<body>
<h1>My pictures</h1>
<p> Just some shots. </p></br>

EOF


# Print the header to file.
print $out $header;
#--------------------------------------------------#



#--------------------------------------------------#

# WORK
# Do the Voodoo:
# for each folder in gallery/{thumbnails,pictures}
# make a heading, and add the thumbnails/pictures to our gallery
foreach my $folder (@picture_folders) {
   chdir ("$work_dir/$pictures_dir/$folder");
   my @pictures = glob("*");
   
   say $out "\n</br></br>\n<h2>$folder</h2>";
   
   # Create the folder for the thumbnails if it doesn't exist
   unless ( -d "$work_dir/$thumbnails_dir/$folder" ) {
	   say "Creating directory: $work_dir/$thumbnails_dir/$folder";
	   system "mkdir -p $work_dir/$thumbnails_dir/$folder";
   }
   
   foreach my $pic  (@pictures) {
	   # create thumbnail if it doesn't already exist
	   if ( -f "$work_dir/$thumbnails_dir/$folder/$pic" ) {
		   my $line = "<a href=\"$url/$pictures_dir/$folder/$pic\"><img src=\"$url/$thumbnails_dir/$folder/$pic\" alt=\"Desciption\"></a>";
		   say $out $line;
	   }
	   else {
		say "Adding thumbnail for $folder/$pic";
		system "convert -resize 145x145 $work_dir/$pictures_dir/$folder/$pic $work_dir/$thumbnails_dir/$folder/$pic" ;
		my $line = "<a href=\"$url/$pictures_dir/$folder/$pic\"><img src=\"$url/$thumbnails_dir/$folder/$pic\" alt=\"Desciption\"></a>";
		   say $out $line;
	   }
   }
}

# Clean up orphaned thumbnail folders and files
foreach my $folder (@thumbnail_folders) {
	chdir ("$work_dir/$thumbnails_dir/$folder");
	my @thumbnails = glob("*");

# Remove orphaned thumbnail folders
# Stop reading here, and go get more coffee.
#
# If there aren't any orphaned folders, then go through and remove
# orphaned thumbnail files.	
	unless ( -d "$work_dir/$pictures_dir/$folder" ) {
		say "Removing directory: $$work_dir/thumbnails_dir/$folder";
		system "rm -r $work_dir/$thumbnails_dir/$folder";
	}
	else {
		# Remove orphaned thumbnail files
		foreach my $pic (@thumbnails) {
			unless ( -f "$work_dir/$pictures_dir/$folder/$pic" ) {
				say "Removing thumbnail for $folder/$pic";
				system (`rm "$work_dir/$thumbnails_dir/$folder/$pic"`);
			}
		}
	}
}

#--------------------------------------------------#




#--------------------------------------------------#
# FOOTER
my $footer = << "EOF";
\n</br></br>
<p>Powered by Debian, perl and vim</p>
\n</body>\n
</html>

EOF

# PRINT the FOOTER
print $out $footer;
#--------------------------------------------------#



#--------------------------------------------------#
# DONE
close $out;
#--------------------------------------------------#
