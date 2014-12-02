#
#   Copyright 2013 Michał Rus <m@michalrus.com>
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#

#
# Loosely based on https://github.com/cjdev/irssi-email-notifier .
#

use strict;
use warnings;

use vars qw($VERSION %IRSSI);

use File::Path qw(make_path);
use Time::HiRes qw(gettimeofday);
use Data::Dumper;

use Irssi;
$VERSION = '0.0.1';
%IRSSI = (
	authors     => 'Michał Rus',
	contact     => 'm@michalrus.com',
	name        => 'email-notify',
	description => 'Saves all hilights to ~/.irssi/email-notify/ .',
	url         => 'https://github.com/michalrus/irssi-email-notify',
	license     => 'Apache License, Version 2.0'
);

my $dir = $ENV{HOME} . '/.irssi/email-notify/';
if (!-d $dir) {
	make_path $dir or die $! . ': failed to create ' . $dir;
}

sub filewrite {
	# check libnotify-client --ping
	my $no_libnotify = system('libnotify-client', '--ping');
	return unless ($no_libnotify);

	my ($text) = @_;
	my ($esec, $eusec) = gettimeofday;
	my $path = $dir . sprintf('%d.%06d000', $esec, $eusec);

	my ($sec, $min, $hour) = localtime;
	my $timestamp = sprintf('%02d:%02d:%02d', $hour, $min, $sec);

	open(FP, '>>', $path) or die $! . ': failed to append to ' . $path;
	print FP $timestamp . ' ' . $text . "\n";
	close(FP);
}

sub priv_msg {
	my ($server, $msg, $nick, $address) = @_;

	filewrite('[' . $server->{chatnet} . '] <' . $nick . '> ' . $msg);
}

sub hilight {
	my ($dest, $text, $stripped) = @_;
	if ($dest->{level} & MSGLEVEL_HILIGHT) {
		filewrite('[' . $dest->{server}->{chatnet} . '/' . $dest->{target} . '] ' . $stripped);
	}
}

Irssi::signal_add_last("message private", "priv_msg");
Irssi::signal_add_last("print text", "hilight");
