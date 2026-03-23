import Nightstream.Rv64IM.Generated.Index.AllCases
import Nightstream.Rv64IM.Generated.Index.AlignedMemory
import Nightstream.Rv64IM.Generated.Index.ControlFlow
import Nightstream.Rv64IM.Generated.Index.NativeAlu

namespace Nightstream.Rv64IM.Generated

def nativeAluParityCases : List (ParitySourceCase × ParityDerivedCase) :=
  Nightstream.Rv64IM.Generated.Index.NativeAlu.parityCases

def alignedMemoryParityCases : List (ParitySourceCase × ParityDerivedCase) :=
  Nightstream.Rv64IM.Generated.Index.AlignedMemory.parityCases

def controlFlowParityCases : List (ParitySourceCase × ParityDerivedCase) :=
  Nightstream.Rv64IM.Generated.Index.ControlFlow.parityCases

def parityCases : List (ParitySourceCase × ParityDerivedCase) :=
  Nightstream.Rv64IM.Generated.Index.AllCases.parityCases

end Nightstream.Rv64IM.Generated
