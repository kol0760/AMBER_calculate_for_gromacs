# AMBER_calculate_for_gromacs

本脚本基于shell语言和perl语言实现了使用Amber力场自动化处理蛋白质和配体小分子，并对其复合物模型进行分子动力学处理的功能

前期准备
-------

需要准备AmberTools套组<br>
```bash
  conda create --name AmberTools23
  conda activate AmberTools23
  conda install -c conda-forge ambertools=23
 ``` 
perl.pl主要进行以下步骤
-------

1，提取小分子的拓扑结构<br>
2，将小分子的GAFF力场参数复制到AMBER14的力场文件中<br>
3，修改topol.top的内容<br>
4，为蛋白质和小分子分别添加位置限制<br>

run.sh则负责为具有RESP电荷的小分子生成GAFF力场，并转换为gromacs可读的模式。
------

这一部分主要依靠antechamber,parmchk2,tleap和acpype实现


后续目标
-------
实现RESP电荷的自动计算<br>
简化生成ligand.top的步骤
