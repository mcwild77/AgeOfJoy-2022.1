using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.XR.Interaction.Toolkit.Inputs;
using UnityEngine.XR;
using UnityEngine.XR.Interaction.Toolkit;
using UnityEngine.InputSystem;
using UnityEngine.XR.Interaction.Toolkit.Inputs;


public class LibretroControlMap : MonoBehaviour
{
    [Tooltip("The Game action map.")]
    public InputActionMap actionMap;

    // [Tooltip("The global action manager in the main rig")]
    // public InputActionManager inputActionManager;
    private const int wheelDelta = 120;

    /*
    public void LoadConfigurationFromFile(string filename)
    {
      ControlMapConfiguration conf = ControlMapConfiguration.LoadFromYaml(filename);
      if (conf == null)
      {
        conf = DefaultControlMap.Instance;
      }
      ConfigManager.WriteConsole($"[LoadConfigurationFromFile] load config {conf}");
      //ConfigManager.WriteConsole(conf.asMarkdown());
      Debug.Log(conf.AsMarkdown());
      conf.ToDebug();

      actionMap = ControlMapInputAction.inputActionMapFromConfiguration(conf);
    }
    */

    //load the control map from the cabinet configuration, if not found fall to the default one.
    //in fact merge any other control map with the default. 
    public void CreateFromConfiguration(
        ControlMapConfiguration conf,
        string fileNameToSaveOrEmpty = "")
    {
        /*
        ControlMapConfiguration conf;

        if (userConfiguration != null)
        {
          conf = new DefaultControlMap();
          conf.Merge(userConfiguration);
          ConfigManager.WriteConsole($"[LibretroControlMap.LoadConfigurationFromCabinet] loaded config from USER configuration: {conf}");
        }
        else if (globalConfiguration != null)
        {
          conf = new DefaultControlMap();
          conf.Merge(globalConfiguration);
          ConfigManager.WriteConsole($"[LibretroControlMap.LoadConfigurationFromCabinet] loaded config from GLOBAL configuration: {conf}");
        }
        else if (cabMapConfiguration != null) 
        {
          conf = new DefaultControlMap();
          conf.Merge(cabMapConfiguration);
          ConfigManager.WriteConsole($"[LibretroControlMap.LoadConfigurationFromCabinet] loaded config from cabinet information (description.yaml): {conf}");
        }
        else {
          conf = DefaultControlMap.Instance;
          ConfigManager.WriteConsole($"[LibretroControlMap.LoadConfigurationFromCabinet] fall to deafult control configuration: {conf}");
        }
        */
        //ConfigManager.WriteConsole(conf.asMarkdown());
        Debug.Log(conf.AsMarkdown());
        conf.ToDebug();

        if (fileNameToSaveOrEmpty != "")
        {
            conf.SaveAsYaml(fileNameToSaveOrEmpty);
        }

        actionMap = ControlMapInputAction.inputActionMapFromConfiguration(conf);
    }
    public int Active(string mameControl)
    {
        int ret = 0;

        InputAction action = actionMap.FindAction(mameControl);
        if (action == null)
        {
            //ConfigManager.WriteConsoleError($"[LibretroControlMap.Active] [{mameControl}] not found in controlMap");
            return 0;
        }

        //https://docs.unity3d.com/Packages/com.unity.inputsystem@1.5/api/UnityEngine.InputSystem.InputAction.html#UnityEngine_InputSystem_InputAction_WasPerformedThisFrame
        if (action.type == InputActionType.Button)
        {
            if (action.IsPressed())
            {
                ConfigManager.WriteConsole($"[LibretroControlMap.Active] {mameControl} pressed");
                return 1;
            }
            return 0;
        }

        else if (action.type == InputActionType.Value)
        {
            Vector2 val = action.ReadValue<Vector2>();
            switch (mameControl)
            {
                case "JOYPAD_UP":
                    if (val.y > 0.5)
                    {
                        ConfigManager.WriteConsole($"{mameControl}: val: {val}");
                        return 1;
                    }
                    break;
                case "JOYPAD_DOWN":
                    if (val.y < -0.5)
                    {
                        ConfigManager.WriteConsole($"{mameControl}: val: {val}");
                        return 1;
                    }
                    break;
                case "JOYPAD_RIGHT":
                    if (val.x > 0.5)
                    {
                        ConfigManager.WriteConsole($"{mameControl}: val: {val}");
                        return 1;
                    }
                    break;
                case "JOYPAD_LEFT":
                    if (val.x < -0.5)
                    {
                        ConfigManager.WriteConsole($"{mameControl}: val: {val}");
                        return 1;
                    }
                    break;
                case "MOUSE_X":
                    //left-to-right movement, range of [-0x7fff, 0x7fff], -32768 to 32767
                    if (val.x > 0.5)
                        ret = 10;
                    else if (val.x < -0.5)
                        ret = -10;
                    break;
                case "MOUSE_Y":
                    //left-to-right movement, range of [-0x7fff, 0x7fff], -32768 to 32767
                    if (val.y > 0.5)
                        ret = 10;
                    else if (val.y < -0.5)
                        ret = -10;
                    break;
                case "MOUSE_WHEELUP":
                    //left-to-right movement, range of [-0x7fff, 0x7fff], -32768 to 32767
                    if (val.y > wheelDelta)
                        ret = 10;
                    break;
                case "MOUSE_WHEELDOWN":
                    //left-to-right movement, range of [-0x7fff, 0x7fff], -32768 to 32767
                    if (val.y < -wheelDelta)
                        ret = -10;
                    break;
                case "MOUSE_HORIZ_WHEELUP":
                    //left-to-right movement, range of [-0x7fff, 0x7fff], -32768 to 32767
                    if (val.x > wheelDelta)
                        ret = 10;
                    break;
                case "MOUSE_HORIZ_WHEELDOWN":
                    //left-to-right movement, range of [-0x7fff, 0x7fff], -32768 to 32767
                    if (val.x < -wheelDelta)
                        ret = -10;
                    break;
            }
        }
        return ret;
    }


    public void Enable(bool enable)
    {
        if (enable)
        {
            actionMap.Enable();
            // inputActionManager.DisableInput();
            return;
        }
        actionMap.Disable();
        // inputActionManager.EnableInput();
        return;
    }

}
