# LubosPB
Addon for writing scripts to semi-automate pet battles in WoW 5.4.8

Open the gui window with command '/lubos' or '/lubospb'. You have to create your script first. After every loading, you have to select active script again.


Example code is below. This Addon was made for personal use, so there is no wiki or more instructions.
Everyone feel free to add whatever functions to suit your needs.
Since there exists a more complex addon with the same functionality on 7.3.5 I won't be maintaining this project.

I am very aware, that this Addon is not user friendly, but it doesn't need to be for my use.


```
if GetActivePet(PLAYER) == 1 then
			if GetPetCurrentHP(PLAYER, 1) == 0 then
				ChangeToPet(2);
				MyMod();
			elseif GetActivePet(ENEMY) == 1 or GetActivePet(ENEMY) == 2 then
				if turn == 0 then
					UseAbility(1);
				elseif turn == 1 then
					UseAbility(2);
				elseif BuffExists(823, buffs, buffs_count) then			
					if buffs[buff_index][1] == 1 then
						UseAbility(2);
					else
						UseAbility(1);
					end
				else 
					print("Error: xd");
				end
			elseif GetActivePet(ENEMY) == 3 then
				if BuffExists(823, buffs, buffs_count) then			
					if buffs[buff_index][1] == 1 then
						UseAbility(2);
					elseif buffs[buff_index][1] >= 4 and GetPetCurrentHP(PLAYER, 1) < 1300 then
						UseAbility(3);
					else
						UseAbility(1);
					end
				end
			end
		elseif GetActivePet(PLAYER) == 2 then
			if GetPetCurrentHP(PLAYER, 2) == 0 then
				ChangeToPet(3);
			elseif GetActivePet(ENEMY) == 2 then
				UseAbility(1);
			elseif GetActivePet(ENEMY) == 3 then
				if turn == 0 then
					UseAbility(1);
				elseif turn == 1 then
					UseAbility(2);
				elseif turn == 2 then
					UseAbility(3);
				end
			end
		elseif GetActivePet(PLAYER) == 3 then
			UseAbility(3);
			UseAbility(1);
		end		
```
