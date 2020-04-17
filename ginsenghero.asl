// Ginseng Hero Autosplitter and load remover by Vis Major.
// Thanks to DevilSquirrel for the Unity autosplitters guide.

state("Ginseng Hero", "1.0") {}
state("ginsenghero_windows", "1.1") {}

startup 
{

    settings.Add("weapon1", true, "Split on first weapon");
    settings.SetToolTip("weapon1", "Happens twice in death abuse route");
    settings.Add("death", false, "Split on death");
    settings.Add("bosses", true, "Split on first two boss kills");
    settings.Add("wings", true, "Split on wings acquired");
    settings.Add("ferry", true, "Split on taking the ferry");
    settings.Add("ginseng", true, "Split on grabbing the ginseng");
    settings.Add("outro", true, "Split on entering the outro");
}

init 
{   
    var version = 0;
    if(game.ProcessName.Equals("Ginseng Hero")) {
        print("version 1");
        version = 1;
        vars.gameManagerTarget = new SigScanTarget(62, "55 48 8B EC 48 81 EC 60 01 00 00 48 89 75 D0 48 89 7D D8 4C 89 65 E0 4C 89 6D E8 4C 89 75 F0 4C 89 7D F8 48 8B F1 ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ??");
    } else {
        print("version 2");
        version = 2;
        vars.gameManagerTarget = new SigScanTarget(58, "55 48 8B EC 48 81 EC 50 01 00 00 48 89 75 D8 48 89 7D E0 4C 89 6D E8");

        //vars.setupManagerTarget = new SigScanTarget(197, "55 48 8B EC 48 81 EC 50 01 00 00 48 89 75 D8 48 89 7D E0 4C 89 6D E8");
    }
    vars.ptr = IntPtr.Zero;
    vars.ptr2 = IntPtr.Zero;
    vars.deaths = 0;
    foreach (var page in game.MemoryPages(true)) {
        var scanner = new SignatureScanner(game, page.BaseAddress, (int)page.RegionSize);
        if( vars.ptr == IntPtr.Zero) { 
            vars.ptr = scanner.Scan(vars.gameManagerTarget);
            if(version == 2)
            {
                vars.ptr2 = vars.ptr == IntPtr.Zero ? IntPtr.Zero : (IntPtr)(vars.ptr + 139);
            }
        } else {
            print("pointer found");
            break;
        }
    }
    
    if (vars.ptr == IntPtr.Zero && ( (vars.ptr2 == IntPtr.Zero) == !(version == 1))) {
        Thread.Sleep(100);
        throw new Exception("Failed to scan for pointers");
    }
    if(version == 1) {
        vars.goingToOtherArea = new MemoryWatcher<bool>(new DeepPointer(vars.ptr, 0x0, 0x765));
        vars.inAreaTransitionDur = new MemoryWatcher<int>(new DeepPointer(vars.ptr, 0x0, 0x770));
        vars.inAreaTransitionCounter = new MemoryWatcher<int>(new DeepPointer(vars.ptr, 0x0, 0x774));
        vars.playerInTitle = new MemoryWatcher<bool>(new DeepPointer(vars.ptr, 0x0, 0x644));
        vars.playerInIntro = new MemoryWatcher<bool>(new DeepPointer(vars.ptr, 0x0, 0x658));
        vars.playerDead = new MemoryWatcher<bool>(new DeepPointer(vars.ptr, 0x0, 0x799));
        vars.playerGrabbedStartWeapon = new MemoryWatcher<bool>(new DeepPointer(vars.ptr, 0x0, 0x7bd));
        vars.playerBossesDefeatedCount = new MemoryWatcher<int>(new DeepPointer(vars.ptr, 0x0, 0x7d0));
        vars.playerGotWings = new MemoryWatcher<bool>(new DeepPointer(vars.ptr, 0x0, 0x7c1));
        vars.playerTookFerry = new MemoryWatcher<int>(new DeepPointer(vars.ptr, 0x0, 0x7c8));
        vars.playerGrabbedGinseng = new MemoryWatcher<bool>(new DeepPointer(vars.ptr, 0x0, 0x681));
        vars.playerInOutro = new MemoryWatcher<bool>(new DeepPointer(vars.ptr, 0x0, 0x665));
    } else if(version == 2) {
        vars.goingToOtherArea = new MemoryWatcher<bool>(new DeepPointer(vars.ptr, 0x0, 0x779));
        vars.inAreaTransitionDur = new MemoryWatcher<int>(new DeepPointer(vars.ptr, 0x0, 0x784));
        vars.inAreaTransitionCounter = new MemoryWatcher<int>(new DeepPointer(vars.ptr, 0x0, 0x788));
        vars.playerInTitle = new MemoryWatcher<bool>(new DeepPointer(vars.ptr, 0x0, 0x65c));
        vars.playerInIntro = new MemoryWatcher<bool>(new DeepPointer(vars.ptr, 0x0, 0x670));
        vars.playerDead = new MemoryWatcher<bool>(new DeepPointer(vars.ptr, 0x0, 0x7b8));
        vars.playerGrabbedStartWeapon = new MemoryWatcher<bool>(new DeepPointer(vars.ptr2, 0x0, 0xb2));
        vars.playerBossesDefeatedCount = new MemoryWatcher<int>(new DeepPointer(vars.ptr2, 0x0, 0xd0));
        vars.playerGotWings = new MemoryWatcher<bool>(new DeepPointer(vars.ptr2, 0x0, 0xb0));
        vars.playerTookFerry = new MemoryWatcher<bool>(new DeepPointer(vars.ptr, 0x0, 0x7de));
        vars.playerGrabbedGinseng = new MemoryWatcher<bool>(new DeepPointer(vars.ptr, 0x0, 0x699));
        vars.playerInOutro = new MemoryWatcher<bool>(new DeepPointer(vars.ptr, 0x0, 0x67d));
    }

    
}

update
{
    vars.goingToOtherArea.Update(game);
    vars.inAreaTransitionDur.Update(game);
    vars.inAreaTransitionCounter.Update(game);
    vars.playerInTitle.Update(game);
    vars.playerInIntro.Update(game);
    vars.playerDead.Update(game);
    vars.playerGrabbedStartWeapon.Update(game);
    vars.playerBossesDefeatedCount.Update(game);
    vars.playerGotWings.Update(game);
    vars.playerTookFerry.Update(game);
    vars.playerGrabbedGinseng.Update(game);
    vars.playerInOutro.Update(game);
    if(vars.playerDead.Changed && vars.playerDead.Current == true) {
        vars.deaths++;
    }
}

start
{
    if (!vars.playerInTitle.Current && vars.playerInIntro.Current) {
        vars.deaths = 0;
        return true;
    }
}

isLoading
{
    return (vars.goingToOtherArea.Current)
    || (vars.inAreaTransitionCounter.Current < vars.inAreaTransitionDur.Current);
}

split
{
    return (vars.playerGrabbedStartWeapon.Changed && vars.playerGrabbedStartWeapon.Old == false && settings["weapon1"])
    ||(vars.playerDead.Changed && vars.playerDead.Current == true && settings["death"] && vars.deaths < 2)
    ||(vars.playerGotWings.Changed && settings["wings"])
    ||(vars.playerBossesDefeatedCount.Changed && vars.playerBossesDefeatedCount.Current <3 && settings["bosses"])
    ||(vars.playerTookFerry.Changed && vars.playerTookFerry.Current == true && settings["ferry"])
    ||(vars.playerGrabbedGinseng.Changed && settings["ginseng"])
    ||(vars.playerInOutro.Changed && settings["outro"]); 
}
