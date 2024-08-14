
using UnityEngine;
using System;
using System.Collections;
using System.Collections.Generic;
using YamlDotNet.Serialization; //https://github.com/aaubry/YamlDotNet
using UnityEditor;
using static OVRHaptics;

[Serializable]
public class CabinetAGEBasicInformation
{
    public bool active = true;
    public bool debug = false;

    [YamlMember(Alias = "system-skin", ApplyNamingConventions = false)]
    public string system_skin = "c64";

    // Serialize this field to show it in the editor
    [SerializeField]
    private List<Variable> variables;
    public List<Variable> Variables { get { return variables; } set { variables = value; } }

    [Serializable]
    public class Variable
    {
        public string name; //variable name
        public string type; //STRING or NUMBER
        public string value = ""; //first asigned value.
    }

    [YamlMember(Alias = "after-start", ApplyNamingConventions = false)]
    public string afterStart;
    [YamlMember(Alias = "after-load", ApplyNamingConventions = false)]
    public string afterLoad;
    [YamlMember(Alias = "after-insert-coin", ApplyNamingConventions = false)]
    public string afterInsertCoin;
    [YamlMember(Alias = "after-leave", ApplyNamingConventions = false)]
    public string afterLeave;

    public List<EventInformation> events;

    public void Validate()
    {
        foreach (EventInformation e in events)
        {
            e.Validate();
        }
    }
    
}

[Serializable]
public class EventInformation
{
    //event identification
    [YamlMember(Alias = "event", ApplyNamingConventions = false)]
    public string eventId;
    static string[] validEvents = { "on-timer", "on-always", "on-control-active", "on-insert-coin", "on-custom",
                                    "on-lightgun"};
    
    public string name = "";
    public string program;
    public double delay = 0;
    public List<ControlInformation> controls;

    public void Validate()
    {
        if (string.IsNullOrEmpty(eventId))
            throw new Exception($"AGEBasic Event Id unespecified");

        if (Array.IndexOf(validEvents, eventId) < 0)
            throw new Exception($"AGEBasic Event [{eventId}] unknown");

        if (string.IsNullOrEmpty(program))
            throw new Exception($"AGEBasic Event {eventId} doesn't have a program attached");

        if (eventId == "on-custom" && string.IsNullOrEmpty(name))
            throw new Exception($"AGEBasic Custom Event {eventId} must to specify a distinctive name");

        if (controls != null)
        {
            foreach (var control in controls)
            {
                if (string.IsNullOrEmpty(control.mameControl))
                    throw new Exception($"Event {eventId} one of the control isn't specified");
            }
        }
    }
}

[Serializable]
public class ControlInformation
{
    [YamlMember(Alias = "libretro-id", ApplyNamingConventions = false)]
    public string mameControl;
    public int port = 0;
}

/// Event execution
public class Event
{
    public EventInformation eventInformation;
    
    //AGEBasic
    public BasicVars vars;
    public basicAGE AGEBasic;

    protected DateTime startTime;
    protected bool initialized = false;

    private int triggeredCount = 0;
    protected int triggeredCountMAX = int.MaxValue;

    public Event(EventInformation eventInformation, BasicVars vars, basicAGE agebasic, int triggerCountMAX = int.MaxValue)
    {
        this.eventInformation = eventInformation;
        this.vars = vars;
        this.triggeredCountMAX = triggerCountMAX;
        AGEBasic = agebasic;
    }

    protected bool RegisterTrigger(bool isTriggered)
    {
        if (isTriggered && triggeredCount < triggeredCountMAX)
            triggeredCount++;
        return triggeredCount > 0;
    }
    public bool WasTriggered()
    {
        return triggeredCount > 0;
    }
    public virtual void Init() {
        triggeredCount = 0;
        startTime = DateTime.Now;
        initialized = true;
    }
    public virtual void PrepareToRun() 
    {
        AGEBasic.PrepareToRun(eventInformation.program, vars, 0);
    }

    //run next line
    public virtual YieldInstruction Run(ref bool moreLines)
    {
        YieldInstruction yield;
        yield = AGEBasic.runNextLineCurrentProgram(ref moreLines);
        if (!moreLines)
        {
            triggeredCount --;
            startTime = DateTime.Now;
        }
        return yield;
    }

    protected virtual bool IsTime()
    {
        return (DateTime.Now - startTime).TotalSeconds >= eventInformation.delay;
    }

    public virtual void EvaluateTrigger() { 
        if (eventInformation.delay > 0)
        {
            RegisterTrigger(IsTime());
        }
        RegisterTrigger(false); 
    }
}

public class OnTimer : Event
{
    public OnTimer(EventInformation eventInformation, BasicVars vars, basicAGE agebasic) :
        base(eventInformation, vars, agebasic)
    { }
}

public class OnAlways : Event
{
    public OnAlways(EventInformation eventInformation, BasicVars vars, basicAGE agebasic) :
        base(eventInformation, vars, agebasic, 1)
    { }

    public override void EvaluateTrigger()
    {
        RegisterTrigger(true);
    }
}

public class OnControlActive: Event
{
    public OnControlActive(EventInformation eventInformation, BasicVars vars, basicAGE agebasic) :
        base(eventInformation, vars, agebasic, 1)
    { }

    public override void EvaluateTrigger()
    {
        if (AGEBasic.ConfigCommands.ControlMap == null)
            RegisterTrigger(false);

        bool ontime = base.IsTime();
        if (ontime)
        {
            foreach (var control in eventInformation.controls)
                if (AGEBasic.ConfigCommands.ControlMap.Active(control.mameControl, control.port) == 0)
                { 
                    RegisterTrigger(false);
                    return;
                }
            RegisterTrigger(true);
        }
         RegisterTrigger(false);
    }
}

public class OnInsertCoin : Event
{
    public OnInsertCoin(EventInformation eventInformation, BasicVars vars, basicAGE agebasic) :
        base(eventInformation, vars, agebasic)
    { }

    void OnInsertCoinTrigger()
    {
        RegisterTrigger(true);
    }
    public override void EvaluateTrigger()
    {
    }
    public override void Init()
    {
        AGEBasic.ConfigCommands.CoinSlot.OnInsertCoin.AddListener(OnInsertCoinTrigger);
        base.Init();
    }
}

public class OnCustom : Event
{
    public OnCustom(EventInformation eventInformation, BasicVars vars, basicAGE agebasic) :
        base(eventInformation, vars, agebasic)
    { }

    public void ForceTrigger()
    {
        RegisterTrigger(true);
    }
    public override void EvaluateTrigger() {}

}


public class OnLightGun : Event
{
    public OnLightGun(EventInformation eventInformation, BasicVars vars, basicAGE agebasic) :
        base(eventInformation, vars, agebasic)
    { }

    public override void EvaluateTrigger()
    {
        if (AGEBasic.ConfigCommands.lightGunTarget != null)
        {
            RegisterTrigger(AGEBasic.ConfigCommands.lightGunTarget.GetLastGameObjectHit() != null);
        }
    }
}

public static class EventsFactory
{
    public static Event Factory(EventInformation eventInformation, BasicVars vars, basicAGE agebasic)
    {
        switch (eventInformation.eventId)
        {
            case "on-always":
                return new OnAlways(eventInformation, vars, agebasic);
            case "on-timer":
                return new OnTimer(eventInformation, vars, agebasic);
            case "on-control-active":
                return new OnControlActive(eventInformation, vars, agebasic);
            case "on-insert-coin":
                return new OnInsertCoin(eventInformation, vars, agebasic);
            case "on-custom":
                return new OnCustom(eventInformation, vars, agebasic);
            case "on-lightgun":
                return new OnLightGun(eventInformation, vars, agebasic);
        }

        throw new Exception($"AGEBasic Unknown event: {eventInformation.eventId}");
    }
}

// ----------------------------------------------------------------------------------------------
[RequireComponent(typeof(basicAGE))]
public class CabinetAGEBasic : MonoBehaviour
{

    public basicAGE AGEBasic;

    BasicVars vars = new(); //variable's space.

    public string pathBase;

    public CabinetAGEBasicInformation AGEInfo = new();

    private List<Event> events = new List<Event>();

    private Coroutine coroutine;

    public void SetDebugMode(bool debug)
    {
        AGEBasic.DebugMode = debug;
    }
    public void Init(CabinetAGEBasicInformation AGEInfo,
            string pathBase,
            Cabinet cabinet,
            CoinSlotController coinSlot, 
            LightGunTarget lightGunTarget)
    {
        if (AGEBasic == null)
            AGEBasic = GetComponent<basicAGE>();

        this.AGEInfo = AGEInfo;
        this.pathBase = pathBase;

        AGEBasic.SetCoinSlot(coinSlot);
        AGEBasic.SetCabinet(cabinet);
        AGEBasic.SetCabinetEvents(events);
        AGEBasic.SetLightGunTarget(lightGunTarget);

        if (AGEInfo.Variables != null)
        {       
            //variable injection
            foreach (CabinetAGEBasicInformation.Variable var in AGEInfo.Variables)
            {
                BasicValue bv;
                if (var.type.ToUpper() == "STRING")
                    bv = new BasicValue(var.value, forceType: BasicValue.BasicValueType.String);
                else if (var.type.ToUpper() == "NUMBER")
                    bv = new BasicValue(var.value, forceType: BasicValue.BasicValueType.Number);
                else
                    throw new Exception($"[CabinetAGEBasic.init] AGEBasic variable injection error var: {var.name} value type unknown: {var.type}");

                vars.SetValue(var.name, bv);
                ConfigManager.WriteConsole($"[CabinetAGEBasic.Init] inject variable: {var.name}: {bv}");
            }
        }

        //events ---
        if (AGEInfo.events.Count > 0)
        {
            foreach (EventInformation info in AGEInfo.events)
            {
                Event ev = EventsFactory.Factory(info, vars, AGEBasic);
                if (ev != null)
                    events.Add(ev);
            }

        }
    }

    private bool execute(string prgName, bool blocking = false, int maxExecutionLines = 10000)
    {
        if (string.IsNullOrEmpty(prgName))
            return false;
        
        CompileWhenNeeded(prgName);

        ConfigManager.WriteConsole($"[CabinetAGEBasic.execute] exec {prgName}");
        AGEBasic.Run(prgName, blocking, vars, maxExecutionLines); //async blocking=false
        return true;
    }

    private void CompileWhenNeeded(string prgName)
    {
        if (!AGEBasic.Exists(prgName) /*&& afterInsertCoinException == null*/)
        {
            try
            {
                AGEBasic.ParseFile(pathBase + "/" + prgName);
            }
            catch (CompilationException e)
            {
                ConfigManager.WriteConsoleException($"[CabinetAGEBasic.execute] parsing {prgName}", (Exception)e);
                throw e;
            }
        }
    }
    private IEnumerator RunEvents()
    {
        if (events.Count == 0)
            yield break;

        foreach (Event evt in events)
        {
            // Initialize the event if needed
            evt.Init();
        }

        while (true) // Continuous loop to keep checking for triggered events
        {
            foreach (Event evt in events)
            {
                //check and cache the trigger action
                evt.EvaluateTrigger();
            }
            
            foreach (Event evt in events)
            {
                // Check if the event was triggered
                if (evt.WasTriggered() && !AGEBasic.IsRunning())
                {
                    ConfigManager.WriteConsole($"[CabinetAGEBasic.RunEvents] starting {evt.eventInformation.program}");

                    //prepare
                    CompileWhenNeeded(evt.eventInformation.program);
                    evt.PrepareToRun();

                    //run
                    bool moreLines = true;
                    while (moreLines)
                    {
                        YieldInstruction yield;
                        // Run the event's program
                        yield = evt.Run(ref moreLines);
                        yield return yield;
                    }
                }
            }
            yield return null;
        }
    }

    public void ActivateShader(ShaderScreenBase shader)
    {
        AGEBasic.ScreenGenerator.Init(AGEInfo.system_skin).
                                    ActivateShader(shader);
    }

    public void ExecInsertCoinBas()
    {
        AGEBasic.DebugMode = AGEInfo.debug;
        execute(AGEInfo.afterInsertCoin, maxExecutionLines: 0);

        //  game started, time to start the events corroutine.
        if (events.Count > 0)
            coroutine = StartCoroutine(RunEvents());
    }

    public void StopInsertCoinBas()
    {
        if (AGEBasic.IsRunning(AGEInfo.afterInsertCoin))
            AGEBasic.ForceStop();

        return;
    }

    public void ExecAfterLeaveBas()
    {
        AGEBasic.DebugMode = AGEInfo.debug;
        execute(AGEInfo.afterLeave);
        if (coroutine != null)
            StopCoroutine(coroutine);
    }
    public void ExecAfterLoadBas()
    {
        AGEBasic.DebugMode = AGEInfo.debug;
        execute(AGEInfo.afterLoad);
    }
    /*    public bool ExecAfterStartBas()
        {
            if (ageBasic.IsRunning())
                return false;

            ageBasic.DebugMode = AGEInfo.debug;
            return execute(AGEInfo.afterStart);
        }
        public void StopAfterStartBas()
        {
            if (ageBasic.IsRunning(AGEInfo.afterStart))
                ageBasic.Stop();
        }
    */
}

#if UNITY_EDITOR


[CustomEditor(typeof(CabinetAGEBasic))]
public class CabinetAGEBasicEditor : Editor
{
    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();

        CabinetAGEBasic myScript = (CabinetAGEBasic)target;

        if (GUILayout.Button("Exec Insert Coin Bas"))
        {
            myScript.ExecInsertCoinBas();
        }

        if (GUILayout.Button("Stop Insert Coin Bas"))
        {
            myScript.StopInsertCoinBas();
        }

        if (GUILayout.Button("Exec After Leave Bas"))
        {
            myScript.ExecAfterLeaveBas();
        }

        if (GUILayout.Button("Exec After Load Bas"))
        {
            myScript.ExecAfterLoadBas();
        }

        /*
        if (GUILayout.Button("Exec After Start Bas"))
        {
            myScript.ExecAfterStartBas();
        }

        if (GUILayout.Button("Stop After Start Bas"))
        {
            myScript.StopAfterStartBas();
        }
        */
    }
}
#endif