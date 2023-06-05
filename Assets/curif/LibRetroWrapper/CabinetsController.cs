/*
This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
You should have received a copy of the GNU General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
*/
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Linq;
using System;

//distribute cabinets games in the room for respawn.

public class CabinetsController : MonoBehaviour
{
    public string Room;
    //public LightProbeGroup ClosestLightProbeGroup = null;

    public GameRegistry gameRegistry;

    public bool Loaded = false; //set when the room cabinets where assigned.

    [SerializeField]
    private int cabinetsCount;
    public int CabinetsCount
    {
        get
        {
            return cabinetsCount;
        }
    }

    void Start()
    {
        cabinetsCount = transform.childCount;

        //set cabinets ID.using a For to ensure the order.
        int idx = 0;
        for (idx = 0; idx < cabinetsCount; idx++)
        {
            CabinetController cc = transform.GetChild(idx).gameObject.GetComponent<CabinetController>();
            if (cc == null)
            {
                cc = transform.GetChild(idx).gameObject.AddComponent<CabinetController>();
            }
            if (cc != null)
            {
                cc.game = new();
                cc.game.Position = idx;
            }
        }
        gameRegistry = GameObject.Find("RoomInit").GetComponent<GameRegistry>();
        if (gameRegistry != null)
            StartCoroutine(load());
        else
            ConfigManager.WriteConsoleError("[CabinetsController] gameRegistry component not found");

    }

    public CabinetController GetCabinetControllerByPosition(int position)
    {
        return transform.GetComponentsInChildren<CabinetController>()
            .FirstOrDefault(cc => cc.game.Position == position);
    }

    public CabinetReplace GetCabinetReplaceByPosition(int position)
    {
        return transform.GetComponentsInChildren<CabinetReplace>()
            .FirstOrDefault(cc => cc.game.Position == position);
    }

    public GameObject GetCabinetChildByPosition(int position)
    {
        // Loop through all the child objects
        foreach (Transform childTransform in transform)
        {
            // Get the CabinetController component if it exists
            CabinetController cabinetController = childTransform.GetComponent<CabinetController>();
            if (cabinetController != null && cabinetController.game.Position == position)
            {
                // Return the GameObject if the position matches
                return childTransform.gameObject;
            }

            // Get the CabinetReplace component if it exists
            CabinetReplace cabinetReplace = childTransform.GetComponent<CabinetReplace>();
            if (cabinetReplace != null && cabinetReplace.game.Position == position)
            {
                // Return the GameObject if the position matches
                return childTransform.gameObject;
            }
        }

        // Return null if no GameObject with the specified position was found
        return null;
    }

    IEnumerator load()
    {
        List<CabinetPosition> games = gameRegistry.GetSetCabinetsAssignedToRoom(Room, transform.childCount); //persist registry with the new assignation if any.
        ConfigManager.WriteConsole($"[CabinetsController] Assigned {games.Count} cabinets to room {Room}");
        Loaded = false;
        int idx = 0;
        foreach (CabinetPosition g in games)
        {
            if (g.CabInfo != null)
            {
                /*
                CabinetController cc = transform.GetChild(idx).gameObject.GetComponent<CabinetController>();
                if (cc?.game?.CabinetDBName == null || String.IsNullOrEmpty(cc.game.CabinetDBName))
                {
                    ConfigManager.WriteConsole($"[CabinetsController] Assigned {g.CabInfo.name} to #{idx}");
                    cc.game = g;
                    yield return new WaitForSeconds(1f / 2f);
                }
                else
                    ConfigManager.WriteConsole(
                      $"[CabinetsController.load] child #{idx} don´t have a CabinetController component or was assigned previously.");
                */
                CabinetController cc = GetCabinetControllerByPosition(g.Position);
                if (cc.game?.CabinetDBName == null || String.IsNullOrEmpty(cc.game.CabinetDBName))
                {
                    ConfigManager.WriteConsole($"[CabinetsController] Assigned {g.CabInfo.name} to #{idx}");
                    cc.game = g; //CabinetController will load the cabinet once asigned.
                    yield return new WaitForSeconds(1f / 2f);
                }
                else
                    ConfigManager.WriteConsole($"[CabinetsController.load] child #{idx} don´t have a CabinetController component or was assigned previously.");
            }
            else
            {
                ConfigManager.WriteConsoleError($"[CabinetsController.load] Assigned {g.CabinetDBName} in #{idx} doesn't have a Cabinet Information assigned, possible error when load cabinet.");
            }

            idx++;
        }
        ConfigManager.WriteConsole($"[CabinetsController] loaded to {idx - 1} cabinets");
        Loaded = true;
    }

    public void Replace(int position, string room, string cabinetDBName)
    {
        //replace in the registry
        CabinetPosition toAdd = new();
        toAdd.Room = room;
        toAdd.Position = position;
        toAdd.CabinetDBName = cabinetDBName;

        CabinetPosition toBeReplaced = gameRegistry.GetCabinetPositionInRoom(position, room);
        ConfigManager.WriteConsole($"[CabinetsController.Replace] [{toBeReplaced}] by [{toAdd}] ");
        gameRegistry.Replace(toBeReplaced, toAdd); //persists changes

        //get cabinetReplace component first.
        CabinetReplace cr = GetCabinetReplaceByPosition(position);
        if (cr != null)
        {
            ConfigManager.WriteConsole($"[CabinetController.Replace] replacing a cabinet by [{toAdd}]");
            cr.ReplaceWith(toAdd);
        }
        else
        {
            CabinetController cc = GetCabinetControllerByPosition(position);
            if (cc != null)
            {
                //its a non-loaded cabinet. It will load just with the assignment
                ConfigManager.WriteConsole($"[CabinetController.Replace] adding [{toAdd}] to a not-loaded cabinet. It will load soon...");
                cc.game = toAdd;
            }
            else
            {
                ConfigManager.WriteConsoleError($"[CabinetController.Replace] no cabinet found to replace by [{toAdd}]");
            }
        }
    }
}
