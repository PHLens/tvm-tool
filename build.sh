#set -e
#set -u

display_usage(){
	echo -e "Usage: build.sh [OPTIONS] [VALUE] \n Options: \n -m : model filename, format onnx. \n -t : build target, llvm or cuda, default llvm.  \n -c : camera address. \n -o : output path."	
} 

if [ -z $1 ]; then 
	display_usage
	exit 0
fi
target=llvm
camera_address=rtsp://192.168.1.59/video
output_path=./output
while getopts "m:t:c:o:h?" opt
do
	case ${opt} in
		m)
		model=$OPTARG
		;;
		t)
		target=$OPTARG
		;;
		c)
		camera_address=$OPTARG
		;;
		o)
		output_path=$OPTARG
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

model_prefix=${model%.*}
model_run=$model_prefix".so"

if [ ! -f ${model_run} ]; then #model is not built
	echo "model lib is not built, start building------!"
	docker run --rm -v $(pwd):/workspace phlens/tvm_py_build:arm64 --model ${model} --target ${target}
	if [ $? -ne 0 ]; then
		echo "build failed : "$?
		exit 1
	else
		echo "finish build model!"
	fi
fi

if [ ${target} = llvm ]; then
	device=True
	echo "use cpu inference!"
else
	device=False
	echo "use gpu inference!"
fi

echo "start service----------"
echo "use model lib ${model_run}"

docker run -d -w /workspace -v $(pwd):/workspace phlens/tvm_opencv_runtime:arm64 python3 little_model.py --model ${model_run} --cpu ${device} --camera_address ${camera_address} --output_path ${output_path}

if [ $? -ne 0 ]; then
    echo "start failed : "$?
    exit 1
else
    echo "Successful start service!"
fi

