#!/usr/bin/perl

# $Id: GenDia.pm,v 1.1 2003/03/21 16:18:03 itamarc Exp $

package GenDia;

use strict;

my $debug = 0;

###### Valores iniciais
my $left = 1.0;
my $top = 5.0;
my $x1 = $left;
my $y1 = $top;
my $x2 = $x1 - 0.05;
my $y2 = $y1 - 0.05;
my $width = 12;
my $height = 30;
my $x3 = $x2 + $width + 0.1;
my $y3 = $y2 + $height + 0.1;
######

=pod



=cut

sub new {
	my $self = shift;
	my %params = @_;
	my $class = ref($self) || $self;
	$self = \%params;
	bless $self, $class;
	$debug = $self->{debug};
	return $self;
}

sub setOutfile {
	my $self = shift;
	my $path = shift;
	$self->{outfile} = $path;
}

sub setData {
	my $self = shift;
	my $data = shift;
	$self->{data} = $data;
}

sub setFk {
	my $self = shift;
	my $fk = shift;
	$self->{fk} = $fk;
}

sub store {
	my $self = shift;
	$self->genXml();
	open(ARQ,">".$self->{outfile});
	print ARQ $self->{XML};
	close(ARQ);
}

sub genXml {
	my $self = shift;
	$self->{XML} = $self->getHeader();
	# List table names ordered by name
	my @tables = sort { $a cmp $b } keys %{$self->{data}};
	# Loop over table data
	foreach my $table (@tables) {
		# Criar classe
		$self->{XML} .= $self->getObjHeader($table);
		my @fields = sort { $a cmp $b } keys %{$self->{data}{$table}{FIELDS}};
		# Para cada campo
		foreach my $field (@fields) {
			# Criar atributo
			$self->{XML} .= $self->getAttrib($field,$self->{data}{$table}{FIELDS}{$field});
		}
		$self->{XML} .= $self->getObjFooter();
	}

	# Loop over FK data
	use Data::Dump qw(dump);
	#dump($self->{fk});
	#die('-');
	foreach my $row (@{$self->{fk}}) {
		#dump($row);
		$self->{XML} .= $self->getAssocObject($row->[0], $row->[1], $row->[2], $row->[3], $row->[4]);
	}
	
	# over-all footer
	$self->{XML} .= $self->getFooter();
}

sub getHeader {
	my $self = shift;
	print "Creating header...\n" if $debug;
	my $header = <<END;
<?xml version="1.0" encoding="UTF-8"?>
<dia:diagram xmlns:dia="http://www.lysator.liu.se/~alla/dia/">
  <dia:diagramdata>
    <dia:attribute name="background">
      <dia:color val="#ffffff"/>
    </dia:attribute>
    <dia:attribute name="paper">
      <dia:composite type="paper">
        <dia:attribute name="name">
          <dia:string>#A4#</dia:string>
        </dia:attribute>
        <dia:attribute name="tmargin">
          <dia:real val="2.8222"/>
        </dia:attribute>
        <dia:attribute name="bmargin">
          <dia:real val="2.8222"/>
        </dia:attribute>
        <dia:attribute name="lmargin">
          <dia:real val="2.8222"/>
        </dia:attribute>
        <dia:attribute name="rmargin">
          <dia:real val="2.8222"/>
        </dia:attribute>
        <dia:attribute name="is_portrait">
          <dia:boolean val="true"/>
        </dia:attribute>
        <dia:attribute name="scaling">
          <dia:real val="1"/>
        </dia:attribute>
        <dia:attribute name="fitto">
          <dia:boolean val="false"/>
        </dia:attribute>
      </dia:composite>
    </dia:attribute>
    <dia:attribute name="grid">
      <dia:composite type="grid">
        <dia:attribute name="width_x">
          <dia:real val="1"/>
        </dia:attribute>
        <dia:attribute name="width_y">
          <dia:real val="1"/>
        </dia:attribute>
        <dia:attribute name="visible_x">
          <dia:int val="1"/>
        </dia:attribute>
        <dia:attribute name="visible_y">
          <dia:int val="1"/>
        </dia:attribute>
      </dia:composite>
    </dia:attribute>
    <dia:attribute name="guides">
      <dia:composite type="guides">
        <dia:attribute name="hguides"/>
        <dia:attribute name="vguides"/>
      </dia:composite>
    </dia:attribute>
  </dia:diagramdata>
  <dia:layer name="Segundo Plano" visible="true">
END
	return $header;
}

sub getFooter {
	my $self = shift;
	print "Creating footer...\n" if $debug;
	my $footer = <<END;
  </dia:layer>
</dia:diagram>
END
	return $footer;
}

sub calcPosition {
	my $self = shift;
	my $xinc = 15;
	my $yinc = 40;
	$x1 += $xinc;
	$x2 += $xinc;
	$x3 += $xinc;
	if ($x1 > ($left+(10*$xinc))) {
		$x1 = $left;
		$x2 = $x1 - 0.05;
		$x3 = $x2 + $width + 0.1;
		$y1 += $yinc;
		$y2 += $yinc;
		$y3 += $yinc;
	}
}

##
# Dia object for a class
##
sub getObjHeader {
	my $self = shift;
	my $nome = shift;
	print "Creating object $nome...\n" if $debug;
	my $header = <<END;
	
    <dia:object type="UML - Class" version="0" id="tbl_$nome">
      <dia:attribute name="obj_pos">
        <dia:point val="$x1,$y1"/>
      </dia:attribute>
      <dia:attribute name="obj_bb">
        <dia:rectangle val="$x2,$y2;$x3,$y3"/>
      </dia:attribute>
      <dia:attribute name="elem_corner">
        <dia:point val="$x1,$y1"/>
      </dia:attribute>
      <dia:attribute name="elem_width">
        <dia:real val="$width"/>
      </dia:attribute>
      <dia:attribute name="elem_height">
        <dia:real val="$height"/>
      </dia:attribute>
      <dia:attribute name="name">
        <dia:string>#$nome#</dia:string>
      </dia:attribute>
      <dia:attribute name="stereotype">
        <dia:string/>
      </dia:attribute>
      <dia:attribute name="abstract">
        <dia:boolean val="false"/>
      </dia:attribute>
      <dia:attribute name="suppress_attributes">
        <dia:boolean val="false"/>
      </dia:attribute>
      <dia:attribute name="suppress_operations">
        <dia:boolean val="false"/>
      </dia:attribute>
      <dia:attribute name="visible_attributes">
        <dia:boolean val="true"/>
      </dia:attribute>
      <dia:attribute name="visible_operations">
        <dia:boolean val="true"/>
      </dia:attribute>
      <dia:attribute name="foreground_color">
        <dia:color val="#000000"/>
      </dia:attribute>
      <dia:attribute name="background_color">
        <dia:color val="#ffffff"/>
      </dia:attribute>
      <dia:attribute name="normal_font">
        <dia:font name="Courier"/>
      </dia:attribute>
      <dia:attribute name="abstract_font">
        <dia:font name="Courier-Oblique"/>
      </dia:attribute>
      <dia:attribute name="classname_font">
        <dia:font name="Helvetica-Bold"/>
      </dia:attribute>
      <dia:attribute name="abstract_classname_font">
        <dia:font name="Helvetica-BoldOblique"/>
      </dia:attribute>
      <dia:attribute name="font_height">
        <dia:real val="0.8"/>
      </dia:attribute>
      <dia:attribute name="abstract_font_height">
        <dia:real val="0.8"/>
      </dia:attribute>
      <dia:attribute name="classname_font_height">
        <dia:real val="1"/>
      </dia:attribute>
      <dia:attribute name="abstract_classname_font_height">
        <dia:real val="1"/>
      </dia:attribute>
      <dia:attribute name="attributes">
END
	&calcPosition();
	return $header;
}

sub getObjFooter {
	my $self = shift;
	my $footer = <<END;
      </dia:attribute>
      <dia:attribute name="operations"/>
      <dia:attribute name="template">
        <dia:boolean val="false"/>
      </dia:attribute>
      <dia:attribute name="templates"/>
    </dia:object>
END
	return $footer;
}

sub getAttrib {
	my $self = shift;
	my ($nome,$tipo) = @_;
	my $attr = <<END;
        <dia:composite type="umlattribute">
          <dia:attribute name="name">
            <dia:string>#$nome#</dia:string>
          </dia:attribute>
          <dia:attribute name="type">
            <dia:string>#$tipo#</dia:string>
          </dia:attribute>
          <dia:attribute name="value">
            <dia:string/>
          </dia:attribute>
          <dia:attribute name="visibility">
            <dia:enum val="0"/>
          </dia:attribute>
          <dia:attribute name="abstract">
            <dia:boolean val="false"/>
          </dia:attribute>
          <dia:attribute name="class_scope">
            <dia:boolean val="false"/>
          </dia:attribute>
        </dia:composite>
END
	return $attr;
}

##
# Dia object for an association (connection)
#
#	* constraint_name -- could be used as an assoc. name.
#	* table_name -- use to identify side A object. Would be easier if object ids would be equal to table names...
#	* foreign_table_name -- use to identify side B object.
#	* column_name -- use as a role A.
#	* foreign_column_name -- use as a role B.
##
sub getAssocObject {
	my $self = shift;

	my $constraint_name = shift;

	my $table_name = shift;
	my $column_name = shift;

	my $foreign_table_name = shift;
	my $foreign_column_name = shift;

	print "Creating association $constraint_name for $table_name...\n" if $debug;

	my $xmlText = <<END;

    <dia:object type="UML - Association" version="2" id="assoc_$constraint_name">
      <dia:attribute name="name">
        <dia:string>#$constraint_name#</dia:string>
      </dia:attribute>
      <dia:attribute name="show_direction">
        <dia:boolean val="false"/>
      </dia:attribute>
      <dia:attribute name="assoc_type">
        <dia:enum val="0"/>
      </dia:attribute>
	  
      <dia:attribute name="role_a">
        <dia:string>#$column_name#</dia:string>
      </dia:attribute>
      <dia:attribute name="multipicity_a">
        <dia:string>#0..*?#</dia:string>
      </dia:attribute>
      <dia:attribute name="visibility_a">
        <dia:enum val="0"/>
      </dia:attribute>
      <dia:attribute name="show_arrow_a">
        <dia:boolean val="false"/>
      </dia:attribute>
	  
      <dia:attribute name="role_b">
        <dia:string>#$foreign_column_name#</dia:string>
      </dia:attribute>
      <dia:attribute name="multipicity_b">
        <dia:string>#1?#</dia:string>
      </dia:attribute>
      <dia:attribute name="visibility_b">
        <dia:enum val="0"/>
      </dia:attribute>
      <dia:attribute name="show_arrow_b">
        <dia:boolean val="true"/>
      </dia:attribute>
	  
      <dia:attribute name="orth_autoroute">
        <dia:boolean val="true"/>
      </dia:attribute>
	  
      <dia:connections>
        <dia:connection handle="0" to="tbl_$table_name" connection="3" />
        <dia:connection handle="1" to="tbl_$foreign_table_name" connection="4" />
      </dia:connections>
    </dia:object>
END
	return $xmlText;
}

1;

