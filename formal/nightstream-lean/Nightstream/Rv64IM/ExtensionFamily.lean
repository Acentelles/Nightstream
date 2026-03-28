namespace Nightstream.Rv64IM

inductive ExtensionFamily where
  | fetch
  | executionRow
  | aluSubtables
  | branchCondition
  | registerHistory
  | ramHistory
deriving DecidableEq, Repr

end Nightstream.Rv64IM
