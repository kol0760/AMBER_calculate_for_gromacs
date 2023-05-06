#!/usr/bin/perl

use strict;
use warnings;


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
