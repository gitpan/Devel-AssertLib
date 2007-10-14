# $Id: AssertLib.pm,v 1.4 2007/10/14 15:18:38 drhyde Exp $

package Devel::AssertLib;

use strict;
use vars qw($VERSION);
$VERSION = '0.1';
use Config;

use File::Spec;
use File::Temp;

# localising prevents the warningness leaking out of this module
local $^W = 1;    # use warnings is a 5.6-ism

=head1 NAME

Devel::AssertLib - check that a library is available

=head1 DESCRIPTION

Devel::AssertLib is a perl module that checks whether a particular C
library is available, and dies if it is not.

=head1 SYNOPSIS

    use Devel::AssertLib (
        lib => 'jpeg'
    );
    print "You can link to libjpeg\n";

=head1 HOW IT WORKS

Everything is done at module 'use' time.  You pass named parameters
describing how to build and link to the library.  Currently the only
parameter supported is 'lib', which can be a string or an arrayref of
several libraries.  In the future, expect me to add something for
checking that header files are available as well.

It works by trying to compile this:

    int main(void) { return 0; }

and linking it to the specified libraries.  If something pops out the end
which looks executable, then the module simply returns.  If not, it dies.

As a shiny side-effect, you can also check to see if the C compiler works
by simply not passing any 'lib' option.

=cut

sub import {
    shift;
    my %args = @_;
    my @libs = join(' ', map { "-l$_" } ref($args{lib}) ? @{$args{lib}} : $args{lib}) if($args{lib});
    my $cc = _findcc();
    my($ch, $cfile) = File::Temp::tempfile('assertlibXXXXXXXX', SUFFIX => '.c');
    my(undef, $exefile) = File::Temp::tempfile('assertlibXXXXXXXX');
    print $ch "int main(void) { return 0; }\n";
    close($ch);

    my $rv = system("$cc -o $exefile $cfile ".join(' ', @libs)." 2>/dev/null");
    my $is_exe = -x $exefile;
    unlink($exefile, $cfile);

    die("Can't build and link to one of [". join(', ', @libs)."]\n")
        unless($is_exe  && $rv == 0);
}

sub _findcc {
    my @paths = split(/$Config{path_sep}/, $ENV{PATH});
    foreach my $path (@paths) {
        if(-x File::Spec->catfile($path, 'cc')) {
            return File::Spec->catfile($path, 'cc');
        } elsif(-x File::Spec->catfile($path, 'gcc')) {
            return File::Spec->catfile($path, 'gcc');
        }
    }
    die("Couldn't find your C compiler\n");
}

=head1 PLATFORMS SUPPORTED

You must have a C compiler installed.  We assume that we will find either
C<cc> or C<gcc> in the $PATH and simply use that.

Probably contains unsupportable assumptions about how to invoke the
compilers and stuff.

=head1 WARNINGS, BUGS and FEEDBACK

This is a very early release intended primarily for feedback from
people who have discussed it.  The interface may change and it has
not been adequately tested.

I welcome feedback about my code, including constructive criticism.
Bug reports should be made using L<http://rt.cpan.org/> or by email.

If you are feeling particularly generous you can encourage me in my
open source endeavours by buying me something from my wishlist:
  L<http://www.cantrell.org.uk/david/wishlist/>

=head1 SEE ALSO

L<Devel::CheckOS>

=head1 AUTHOR

David Cantrell E<lt>F<david@cantrell.org.uk>E<gt>

Thanks to the cpan-testers-discuss mailing list for prompting me to write it
in the first place.

=head1 COPYRIGHT and LICENCE

Copyright 2007 David Cantrell

This module is free-as-in-speech software, and may be used, distributed,
and modified under the same conditions as perl itself.

=head1 CONSPIRACY

This module is also free-as-in-mason software.

=cut

1;
