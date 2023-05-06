#!/usr/bin/perl


use strict;
use warnings;

# 提取GAFF力场所属的分子类型
my $ligand_top = "./top/ligand.top";
open(my $fh_ligand_top, '<', $ligand_top) or die "Could not open file '$ligand_top' $!";

my $atomtypes = "";

while (my $line = <$fh_ligand_top>) {
    if ($line =~ /^\[ atomtypes \]/) {
        while ($line = <$fh_ligand_top>) {
            last if $line =~ /^\[/;
            $atomtypes .= $line;
        }
    }
}
close $fh_ligand_top;

my $atomtypes = "\n; changing added GAFF atom for EDY\n" . $atomtypes;


# 打开另一个文本文件，将其读入到一个字符串中
my $ffnonbonded_file = './amber14sb_parmbsc1.ff/ffnonbonded.itp';#此处要修改
open(my $fh_ffnonbonded, '<', $ffnonbonded_file) or die "无法打开文件: $!";
my $other_text = do { local $/; <$fh_ffnonbonded> };
close($fh_ffnonbonded);

# 将$atomtypes添加到$other_text的末尾
$other_text .= $atomtypes;

# 将修改后的文本写回到原始文本文件中
open(my $out_fh, '>', $ffnonbonded_file) or die "无法打开文件: $!";
print $out_fh $other_text;
close($out_fh);

# 生成gromacs可识别的.top文件，这段脚本肯定可以简化的，但是我不会

my $filename = "./top/ligand.top";

open(my $fh, '<', $filename) or die "Could not open file '$filename' $!";

my $moleculetype = "";
my $atoms = "";
my $bonds = "";
my $pairs = "";
my $angles = "";
my $dihedrals = "";
my $flag = 0;

while (my $line = <$fh>) {
    if ($line =~ /^\[ moleculetype \]/) {
        $flag = 1;
    }
    elsif ($line =~ /^\[ atoms \]/) {
        $flag = 2;
    }
    elsif ($line =~ /^\[ bonds \]/) {
        $flag = 3;
    }
    elsif ($line =~ /^\[ pairs \]/) {
        $flag = 4;
    }
    elsif ($line =~ /^\[ angles \]/) {
        $flag = 5;
    }
    elsif ($line =~ /^\[ dihedrals \]/) {
        $flag = 6;
    }
    elsif ($line =~ /^\[/) {
        $flag = 0;
    }

    if ($flag == 1) {
        $moleculetype .= $line;
    }
    elsif ($flag == 2) {
        $atoms .= $line;
    }
    elsif ($flag == 3) {
        $bonds .= $line;
    }
    elsif ($flag == 4) {
        $pairs .= $line;
    }
    elsif ($flag == 5) {
        $angles .= $line;
    }
    elsif ($flag == 6) {
        $dihedrals .= $line;
    }
}
close($fh);

my $output = "ligand.top";   # 输出文件的路径和名称
open(my $output_fh, '>', $output) or die "无法打开文件 '$output' $!";


print $output_fh "\n$moleculetype\n$atoms\n$bonds\n$pairs\n$angles\n$dihedrals\n";

close($output_fh);


# Open file for reading
open my $input_file, '<', 'topol.top' or die "Could not open file: $!";

# Open temporary file for writing
open my $temp_file, '>', 'temp.top' or die "Could not create temporary file: $!";

# Loop through each line of input file
my $has_added_content = 0;
while (my $line = <$input_file>) {
    if ($line =~ /^\s*#\s*endif/ && !$has_added_content) {
        $has_added_content = 1;
        print $temp_file $line;
        print $temp_file "\n; Include edy topology\n#include \"./ligand.itp\"\n\n; Include edy restraint file\n#ifdef POSRES_LIG\n#include \"./ligand_posre.itp\"\n#endif\n";
    }
    elsif ($line =~ /^\s*#\s*include/) {
        print $temp_file $line;
    }
    else {
        print $temp_file $line;
    }
}

print $temp_file "EDY\t1\n";
# Close files
close $input_file;
close $temp_file;

# Rename temporary file to original file
rename 'topol.top', 'topol_origin.top' or die "Could not rename temporary file: $!";

rename 'temp.top', 'topol.top' or die "Could not rename temporary file: $!";

#生成配体的位置限制文件
# 打开文件ligand.top
open my $fh, '<', 'ligand.top' or die "Cannot open file: $!";

# 定义变量
my @result;
my $flag = 0;

# 逐行读取文件内容
while (my $line = <$fh>) {
    # 如果匹配到 [ atoms ] 开头的行，则标记为需要保存的内容
    if ($line =~ /^\s*\[\s*atoms\s*\]\s*$/) {
        $flag = 1;
        next;
    }

    # 如果已经标记为需要保存的内容，将该行加入数组
    if ($flag) {
        push @result, $line;
        # 如果匹配到空行，说明该段内容已经结束，退出循环
        last if $line =~ /^\s*$/;
    }
}
@result = grep(!/H/, @result);
shift @result;
# 提取数组的第一列
my @col1 = map { (split)[0] } @result;

my $heave_atoms = join("\n", @col1);

$heave_atoms .= "\n";

$heave_atoms =~ s/\n/\t1\tPOSRES_LIG_FC\tPOSRES_LIG_FC\tPOSRES_LIG_FC\n/g;

my $ligand_posre = 0;
$ligand_posre = "\#添加配体的位置限制\n[ position_restraints ]\n; atom  type      fx      fy      fz\n" . $heave_atoms;

# 将变量保存为文件
my $file_ligand_posre = "ligand_posre.itp";
open my $fh_ligand_posre, ">", $file_ligand_posre or die "Cannot open $file_ligand_posre: $!";
print $fh_ligand_posre $ligand_posre;
close $fh_ligand_posre;

#生成蛋白质的位置限制文件
system("sed -i 's/1000\\s\\+1000\\s\\+1000/POSRES_PRO_FC  POSRES_PRO_FC  POSRES_PRO_FC/g' posre.itp");
