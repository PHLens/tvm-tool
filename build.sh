#set -e
#set -u

display_usage(){
	echo -e "Usage: build.sh [OPTIONS] [VALUE] \n Options: \n -m : model filename, format onnx. \n -t : build target, llvm or cuda, default llvm."	
} 

if [ -z $1 ]; then 
	display_usage
	exit 0
fi
target=llvm
while getopts "m:t:f:h?" opt
do
	case ${opt} in
		m)
		model=$OPTARG
		;;
		t)
		target=$OPTARG
		;;
		f)
		filename=$OPTARG
		;;
		*)
		display_usage
		exit 0
		;;
	esac
done
if [ -z $model ]; then
	echo "model file is empty!"
	display_usage
	exit 0
fi
echo "use model ${model}"
echo "use target ${target}"
echo "inference file is ${filename}"

docker run --rm -v $(pwd):/workspace phlens/tvm_py_build:arm64 --model ${model} --target ${target}

if [ $? -ne 0 ]; then
	echo "build failed : "$?
	exit 1
else
	echo "finish build model!"
fi
