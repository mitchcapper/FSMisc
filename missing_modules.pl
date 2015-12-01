#!/usr/bin/perl
use strict;
sub usage()
{
	print "usage: missing_modules.pl [dirs_only] old_perl_root new_perl_root ... new_perl_root3\n";
	print "\tIE: missing_modules.pl 1 /usr/lib/perl5/site_perl/5.8.8/i686-linux/ /usr/lib/perl5/site_perl/5.8.8/i686-linux-thread-multi/ /usr/lib/perl5/vendor_perl/5.8.8/i686-linux-thread-multi/\n";
	exit;
}

my %DIRS;
my %FILES;
my ($dirs_only,$olddir,@new_dirs) = @ARGV;
usage() if ($#ARGV < 2);
foreach my $newdir (@new_dirs)
{
	explore_dir(length($newdir),$newdir);
}
explore_dir(length($olddir),$olddir,1);
sub dir_file_cnt($)
{
	my ($dir) = @_;
	opendir(di,$dir);
	my @files = readdir(di);
	closedir(di);
	my $count = 0;
	foreach my $file (@files)
	{
		chomp($file);
		my $full_path = $dir . "/" . $file;
		next if ($file eq "." || $file eq ".." || $file eq ".packlist" || $file =~ /\.ph$/);
		if (-d $full_path)
		{
			next if (dir_file_cnt($full_path) == 0);
		}
		$count++;
	}
	return $count;
}
sub explore_dir($$)
{
	my($rel_chars,$dir,$notify_missing) = @_;
	my @TO_EXPLORE; #lets avoid going super recursive
	opendir(di,$dir);
	my @files = readdir(di);
	closedir(di);
	foreach my $file (@files)
	{
		chomp($file);
		next if ($file eq "." || $file eq ".." || $file eq ".packlist" || $file =~ /\.ph$/);
		my $full_path = $dir . "/" . $file;
		my $rel_path = substr($full_path,$rel_chars);
		if (-d $full_path)
		{
			print "DIR:  .$rel_path\n" if (! $DIRS{$rel_path} && $notify_missing && dir_file_cnt($full_path) > 0);
			push @TO_EXPLORE, $full_path;
			$DIRS{$rel_path} = 1;
		}
		else
		{
			print "FILE: .$full_path\n" if (! $FILES{$rel_path} && $notify_missing && ! $dirs_only);
			$FILES{$rel_path} = 1;
		}
	}
	foreach my $pending_dir (@TO_EXPLORE)
	{
		explore_dir($rel_chars,$pending_dir,$notify_missing);
	}
}


