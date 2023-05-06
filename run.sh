#! /bin/bash
#一个自动化计算小分子拓扑和蛋白质拓扑的脚本
#小分子采用GAFF力场

source ~/miniconda3/envs/AmberTools22/amber.sh

#新建一个专门用于配体处理的文件夹
mkdir ligand_prepare

cp ligand_resp.mol2 ./ligand_prepare

cd ligand_prepare
antechamber -i ligand_resp.mol2 -fi mol2 -o ligand_resp.prepi -fo prepi -pf y

parmchk2 -i ligand_resp.mol2 -f mol2 -o ligand_resp.frcmod


#使用tleap生成AMBER参数文件及坐标文件

echo "source leaprc.ff14SB
source leaprc.gaff
loadamberparams ligand_resp.frcmod
lig=loadmol2 ligand_resp.mol2
check lig
saveamberparm lig ligand.prmtop ligand.inpcrd
quit">leap.in

tleap -f leap.in

#将AMBER文件转换为GROMACS文件
acpype -p ligand.prmtop -x ligand.inpcrd -d

mkdir ../top
cp EDY.amb2gmx/EDY_GMX.gro ../top
cp EDY.amb2gmx/EDY_GMX.top ../top
cp EDY.amb2gmx/posre_EDY.itp ../top

cd ..

mv top/EDY_GMX.gro top/ligand.gro
mv top/EDY_GMX.top top/ligand.top
mv top/posre_EDY.itp top/ligand.itp

echo -e "1\n1" | ~/app/GROMACS/bin/gmx pdb2gmx -f protein.pdb -o protein.gro

cp ./amber14sb_parmbsc1.ff/ffnonbonded.itp ./amber14sb_parmbsc1.ff/ffnonbonded_origin.itp
#此时会生成有关蛋白质的拓扑文件

#perl.pl负责内容
perl perl.pl
