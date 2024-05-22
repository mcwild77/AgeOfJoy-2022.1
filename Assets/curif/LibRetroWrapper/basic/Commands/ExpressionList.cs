using System;
using System.Collections.Generic;
using System.IO;

class CommandExpressionList : ICommandBase, ICommandList
{
    public string CmdToken { get; } = "EXPRLIST";

    public int MaxAllowed { get { return maxAllowed; } }

    public CommandType.Type Type { get; } = CommandType.Type.ExpressionList;

    const int maxAllowed = 15;
    CommandExpression[] exprs = new CommandExpression[15];

    int count = 0;
    public int Count { get { return count; } private set { count = value; } }

    ConfigurationCommands config;
    public CommandExpressionList(ConfigurationCommands config)
    {
        this.config = config;
    }

    public bool Parse(TokenConsumer tokens)
    {
        AGEBasicDebug.WriteConsole($"[ExpressionList.Parse] START  {tokens.ToString()}");

        int idx = -1;
        do
        {
            tokens.ConsumeIf(",");

            if (idx + 1 > maxAllowed - 1)
                throw new Exception($"More than {maxAllowed} members in an expressionList {tokens.ToString()}");

            AGEBasicDebug.WriteConsole($"[ExpressionList.Parse] parsing  {tokens.ToString()}");
            CommandExpression expr = new(config);
            expr.Parse(tokens);

            idx++;
            exprs[idx] = expr;
        }
        while (tokens.Token == ",");

        this.count = idx + 1;

        AGEBasicDebug.WriteConsole($"[ExpressionList.Parse] END members: {this.Count} {tokens.ToString()}");

        return true;
    }

    public BasicValue Execute(BasicVars vars)
    {
        throw new Exception($"can't exec a expr list");
    }

    public BasicValue[] ExecuteList(BasicVars vars)
    {
        AGEBasicDebug.WriteConsole($"[AGE BASIC {CmdToken}] ExecuteList");
        BasicValue[] vals = new BasicValue[exprs.Length];
        int idx = 0;
        while (exprs[idx] != null)
        {
            AGEBasicDebug.WriteConsole($"[AGE BASIC {CmdToken}] execute expression idx: {idx}");
            ICommandList exprList = exprs[idx] as ICommandList;
            if (exprList != null)
            {
                BasicValue[] nestedVals = exprList.ExecuteList(vars);
                AGEBasicDebug.WriteConsole($"[AGE BASIC {CmdToken}] execute nested valos expression idx: {idx}");

                Array.Resize(ref vals, vals.Length + nestedVals.Length);
                foreach(BasicValue val in nestedVals)
                {
                    vals[idx] = val; 
                    idx++;
                }
            }
            else
            {
                vals[idx] = exprs[idx].Execute(vars);
                idx++;
            }
            
        }
        return vals;
    }
    
    public BasicValue ExecuteByPosition(int idx, BasicVars vars)
    {
        AGEBasicDebug.WriteConsole($"[AGE BASIC {CmdToken}] execute expression idx: {idx}");
        return exprs[idx].Execute(vars);
    }
    
}