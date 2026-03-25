import Nightstream.Rv64IM.Generated.Index.AllCases
import Nightstream.Rv64IM.Generated.Index.AlignedMemory
import Nightstream.Rv64IM.Generated.Index.ControlFlow
import Nightstream.Rv64IM.Generated.Index.Multiply
import Nightstream.Rv64IM.Generated.Index.NarrowMemory
import Nightstream.Rv64IM.Generated.Index.NativeAlu
import Nightstream.Rv64IM.Generated.Index.SignedDivRem
import Nightstream.Rv64IM.Generated.Index.UnsignedDivRem

namespace Nightstream.Rv64IM.Generated

def nativeAluParityCases : List (ParitySourceCase × ParityDerivedCase) :=
  Nightstream.Rv64IM.Generated.Index.NativeAlu.parityCases

def alignedMemoryParityCases : List (ParitySourceCase × ParityDerivedCase) :=
  Nightstream.Rv64IM.Generated.Index.AlignedMemory.parityCases

def narrowMemoryParityCases : List (ParitySourceCase × ParityDerivedCase) :=
  Nightstream.Rv64IM.Generated.Index.NarrowMemory.parityCases

def multiplyParityCases : List (ParitySourceCase × ParityDerivedCase) :=
  Nightstream.Rv64IM.Generated.Index.Multiply.parityCases

def unsignedDivRemParityCases : List (ParitySourceCase × ParityDerivedCase) :=
  Nightstream.Rv64IM.Generated.Index.UnsignedDivRem.parityCases

def signedDivRemParityCases : List (ParitySourceCase × ParityDerivedCase) :=
  Nightstream.Rv64IM.Generated.Index.SignedDivRem.parityCases

def controlFlowParityCases : List (ParitySourceCase × ParityDerivedCase) :=
  Nightstream.Rv64IM.Generated.Index.ControlFlow.parityCases

def parityCases : List (ParitySourceCase × ParityDerivedCase) :=
  Nightstream.Rv64IM.Generated.Index.AllCases.parityCases

end Nightstream.Rv64IM.Generated
