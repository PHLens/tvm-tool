import tvm
from tvm import te
import tvm.relay as relay
from tvm.contrib import utils, graph_executor as runtime
import onnx
import argparse
import os

parser = argparse.ArgumentParser(description='Build Model')
parser.add_argument('-m', '--model', default='mobilenet.onnx',
                    type=str, help='Model file path to open')
parser.add_argument('--target', default="llvm", help='llvm or cuda')
#parser.add_argument('--cpu', action="store_true", default=True, help='Use cpu inference')

args = parser.parse_args()
os.chdir("/workspace")

model = onnx.load(args.model)
input_blob = model.graph.input[0]
input_shape = tuple(map(lambda x: getattr(x, 'dim_value'), input_blob.type.tensor_type.shape.dim))
shape_dict = {input_blob.name: input_shape}
mod, params = relay.frontend.from_onnx(model, shape_dict)

target = args.target
with relay.build_config(opt_level=3):
    lib = relay.build(mod, target, params=params)

lib_fname = args.model.split(".")[0] + ".so"
lib.export_library(lib_fname)
