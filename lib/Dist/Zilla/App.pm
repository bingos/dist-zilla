use strict;
use warnings;
package Dist::Zilla::App;
# ABSTRACT: Dist::Zilla's App::Cmd
use App::Cmd::Setup -app;

use Carp ();
use Dist::Zilla::Config::Finder;
use File::HomeDir ();
use Moose::Autobox;
use Path::Class;

sub config {
  my ($self) = @_;

  my $homedir = File::HomeDir->my_home
    or Carp::croak("couldn't determine home directory");

  my $file = dir($homedir)->file('.dzil');
  return {} unless -e $file;

  if (-d $file) {
    $file = dir($homedir)->subdir('.dzil')->file('config');
    return Dist::Zilla::Config::Finder->new->read_expanded_config({
      root     => $file,
      basename => 'config',
    });
  } else {
    $file = dir($homedir)->subdir('.dzil')->file('config');
    return Dist::Zilla::Config::Finder->new->read_expanded_config({
      filename => "$file",
    });
  }
}

sub config_for {
  my ($self, $plugin_class) = @_;

  return {} unless $self->config->{plugins};

  for my $plugin ($self->config->{plugins}->flatten) {
    return $plugin->[1] if $plugin->[0] eq $plugin_class;
  }

  return {};
}

1;
