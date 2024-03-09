#!/bin/sh -ex

PTS_BASE=$HOME/.phoronix-test-suite
export PTS_BM_BASE="$1"
LLVM_DIR=`pwd`/toolchain
export PTS="php $PTS_BM_BASE/phoronix-test-suite/pts-core/phoronix-test-suite.php"

# Delete previous compiled binaries and previous results
rm -rf $PTS_BM_BASE/installed-tests/*
rm -rf $PTS_BM_BASE/test-results/*
rm -rf $PTS_BM_BASE/test-results-*
rm -rf $PTS_BASE/test-results/*
rm -rf $PTS_BASE/test-results-*

# Download llvm-15 used by pts/build-llvm benchmark
if [ ! -d llvm-project-llvmorg-15.0.7 ]
then
	wget https://codeload.github.com/llvm/llvm-project/tar.gz/refs/tags/llvmorg-15.0.7
	tar xzvf llvmorg-15.0.7
fi

# Download my modified phoronix-test-suite
if [ ! -d $PTS_BM_BASE/phoronix-test-suite ]
then
	(cd $PTS_BM_BASE && git clone https://github.com/lucic71/phoronix-test-suite)
fi

# Download my modified test-profiles
if [ ! -d $PTS_BM_BASE/test-profiles ]
then
	(cd $PTS_BM_BASE && git clone https://github.com/lucic71/test-profiles && \
	 cd test-profiles && git checkout ub && cd .. && rm -rf $PTS_BASE/test-profiles && \
	 cp -r test-profiles $PTS_BASE)
fi

# Install dependencies

export CC=$LLVM_DIR/clang
export CXX=$LLVM_DIR/clang++
export UB_OPT_FLAG="-O2"


./install-profiles.sh $UB_OPT_FLAG
./run-profiles.sh     $UB_OPT_FLAG

mkdir "$PTS_BM_BASE/test-results$UB_OPT_FLAG/" || true
mv -f  $PTS_BASE/test-results/* "$PTS_BM_BASE/test-results$UB_OPT_FLAG/" || true
rm -rf $PTS_BM_BASE/installed-tests/*
