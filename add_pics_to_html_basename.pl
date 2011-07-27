#!/usr/bin/env perl
# add_pics_to_html_basename2.pl
# copyright 2011, m. tornow and fsmithred
# lots of help by telemachus and dbbolton too
# license: GPL-3


#--------------------------------------------------#
# USE
use warnings;
use 5.012_003;
use autodie;
use File::Copy;
use File::Path qw(make_path remove_tree);
use File::Basename;
#--------------------------------------------------#



#--------------------------------------------------#
# VARIABLES
my $work_dir = "$ENV{HOME}/public_html/gallery";
my $pictures_dir = "pictures";
my $thumbnails_dir = "thumbnails";
my $gallery_html = "gallery.html";
my $background_image="pictures/backgrounds/paper3.jpg";

#Change $webhost to a real host name or IP number for public access.
my $webhost = "localhost";

# if /var/www/username exists as symlink to /home/username/public_html:
#my $url = "http://$webhost/$ENV{USER}/gallery";

# if mod userdir is enabled and there's no symlink:
my $url = "http://$webhost/\~$ENV{USER}/gallery";

#--------------------------------------------------#


chdir ("$work_dir/$pictures_dir");
my @picture_folders = glob("*");
chdir ("$work_dir/$thumbnails_dir");
my @thumbnail_folders = glob("*");
chdir ("$work_dir");


#--------------------------------------------------#
# First of all: make a BACKUP
if ( -f $gallery_html ) {
	copy("$gallery_html", "$gallery_html.orig");
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
<link rel="stylesheet" href="../../css/screen-index.css"></head><body style="background-image: url($background_image);">
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
	my @picture_paths =  glob("$pictures_dir/$folder/*" );
	
	my @pictures;
		foreach (@picture_paths) {
			my $picture = fileparse($_);
			push @pictures, $picture;
		}

   say $out "\n</br></br>\n<h2>$folder</h2>";

   # Create the folder for the thumbnails if it doesn't exist
   unless ( -d "$work_dir/$thumbnails_dir/$folder" ) {
	   make_path("$work_dir/$thumbnails_dir/$folder", {
		   verbose => 1,
		   });
   }
   
   foreach my $pic  (@pictures) {
	   # create thumbnail if it doesn't already exist
	   if ( -f "$work_dir/$thumbnails_dir/$folder/$pic" ) {
		   my $line = "<a href=\"$url/$pictures_dir/$folder/$pic\"><img src=\"$url/$thumbnails_dir/$folder/$pic\" alt=\"Desciption\"></a>";
		   say $out $line;
	   }
	   else {
		say "Adding thumbnail for $folder/$pic";
		# use 145x145! to force square thumbnails
		system "convert -resize 125x125 $work_dir/$pictures_dir/$folder/$pic $work_dir/$thumbnails_dir/$folder/$pic" ;
		my $line = "<a href=\"$url/$pictures_dir/$folder/$pic\"><img src=\"$url/$thumbnails_dir/$folder/$pic\" alt=\"Desciption\"></a>";
		   say $out $line;
	   }
   }
}


# Clean up orphaned thumbnail folders and files (Don't use quotes in map, or you get the whole path)
foreach my $folder (@thumbnail_folders) {
	my @thumbnail_paths = glob("$thumbnails_dir/$folder/*" );
	
	my @thumbnails;
	foreach (@thumbnail_paths) {
		my $thumbnail = fileparse($_);
			push @thumbnails, $thumbnail;
		}

# Remove orphaned thumbnail folders
# If there aren't any orphaned folders, then go through and remove
# orphaned thumbnail files.	
	unless ( -d "$work_dir/$pictures_dir/$folder" ) {
		remove_tree("$work_dir/$thumbnails_dir/$folder", {
		   verbose => 1,
		   });
	}
	else {
		# Remove orphaned thumbnail files
		foreach my $pic (@thumbnails) {
			unless ( -f "$work_dir/$pictures_dir/$folder/$pic" ) {
#			# remove_tree works for files, too.
				remove_tree("$work_dir/$thumbnails_dir/$folder/$pic", {
					verbose => 1,
					});
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
