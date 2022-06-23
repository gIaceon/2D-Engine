-- TODO optimize, maybe make it just a single value for a case instead?
export type SwitchAcceptedStatementType = any?;
export type DefaultType = {};
export type CaseType = ({[number]: SwitchAcceptedStatementType}) -> {[number]: SwitchAcceptedStatementType};
export type PassedTable = {[CaseType | DefaultType]: (SwitchAcceptedStatementType, SwitchAcceptedStatementType) -> (...any?)};
export type EvalutateFunctionType = (PassedTable, SwitchAcceptedStatementType) -> ();

local function DefaultEvaluateSwitchCase(Args, Passed_Argument: SwitchAcceptedStatementType): EvalutateFunctionType
	for _,v in ipairs(Args) do
		if (Passed_Argument == v) then
			-- if its the passed argument
			return true, v;
		end;
	end;

	return false, nil;
end;

local function OneValueEvaluateSwitchCase(Arg, Passed_Argument: SwitchAcceptedStatementType): EvalutateFunctionType
	if (Passed_Argument == Arg) then
        -- if its the passed argument
        return true, Arg;
    end;

	return false, nil;
end;

local Default: DefaultType = {};
local Case: CaseType = function(Args)
    return Args;
end;

local mt = {
	__index = {
		Default = Default; 
        Case = Case; 
        DefaultEvaluate = DefaultEvaluateSwitchCase;	
        OneValueEvaluate = OneValueEvaluateSwitchCase;
	}, 
	__call = function(self, Passed_Argument: SwitchAcceptedStatementType?, EvalutateFunction: EvalutateFunctionType?)		
		return function (Passed_Table: PassedTable)
			for CaseOrDefault, CaseFunction in pairs(Passed_Table) do
				if (CaseOrDefault == self.Default) then continue; end; -- Go to the next case if its default.
				local Done, Equal = if EvalutateFunction ~= nil then EvalutateFunction(CaseOrDefault, Passed_Argument) else 
					DefaultEvaluateSwitchCase(CaseOrDefault, Passed_Argument);

				if (Done == true) then return CaseFunction(Equal, Passed_Argument); end;
			end;

			return (Passed_Table[Default])(Passed_Argument);
		end;
	end;
};

return setmetatable({}, mt);