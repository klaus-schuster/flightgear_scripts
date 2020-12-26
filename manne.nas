
# Flaps aus multikey abgucken (while)
# multikey take-off läuft nicht
# after take off - ap richtig einstellen noch nicht ganz automatisiert.
# fertig - thrust zu. idle setzen, nach touchdown?? (kommen sonst die spoiler nicht raus?)
#
#
###
var ac_unknown = 1;
var aircraft = getprop("/sim/aero");


if (left(aircraft,5) == "A330-") {

	aircraft = "A330";


	var fuel_pph = 15000;
	var cruise_mach = 0.84;

setprop("/_manne/cfg/altitude","/it-autoflight/input/alt");
setprop("/_manne/cfg/kts","/it-autoflight/input/spd-kts");
setprop("/_manne/cfg/mach","/it-autoflight/input/spd-mach");
setprop("/_manne/cfg/kts-mach-selector","/it-autoflight/input/kts-mach");
setprop("/_manne/cfg/vs","/it-autoflight/input/vs");
setprop("/_manne/cfg/avg_fuelflow",fuel_pph);
setprop("/_manne/cfg/cruise_mach",cruise_mach);
setprop("/_manne/_autostop",0);

var fuel_flow1 = getprop("/engines/engine/fuel-flow-gph");
var fuel_flow2 = getprop("/engines/engine[1]/fuel-flow-gph");
var alt_prop = getprop("/_manne/cfg/altitude");
print("huhuhuh");
print(alt_prop);
ac_unknown = 0;

}


if (aircraft == "747-8i") {
	var fuel_pph = 30000;
	var cruise_mach = 0.855;
	var fuel_flow1 = getprop("/engines/engine/fuel-flow-gph");
	var fuel_flow2 = getprop("/engines/engine[1]/fuel-flow-gph");
	var fuel_flow3 = getprop("/engines/engine[2]/fuel-flow-gph");
	var fuel_flow4 = getprop("/engines/engine[3]/fuel-flow-gph");
	var alt_prop = "/autopilot/settings/alt-display-ft";
	ac_unknown = 0;
} else if (aircraft == "737-300") {
	var fuel_pph = 8000;
	var cruise_mach = 0.82;
	ac_unknown = 0;
	var fuel_flow1 = getprop("/engines/engine/fuel-flow-pph");
	var fuel_flow2 = getprop("/engines/engine[1]/fuel-flow-pph");
	var alt_prop = "/autopilot/settings/target-altitude-ft";
} else if (aircraft == "737-800YV") {
	var fuel_pph = 8000;
	var cruise_mach = 0.82;
	ac_unknown = 0;
	var fuel_flow1 = getprop("/engines/engine/fuel-flow-pph");
	var fuel_flow2 = getprop("/engines/engine[1]/fuel-flow-pph");
	var alt_prop = "/it-autoflight/input/alt";
} else if (aircraft == "777-200ER"
	or aircraft == "org.flightgear.fgaddon.777-200ER") {
	var fuel_pph = 22000;
	var cruise_mach = 0.84;
	ac_unknown = 0;
	var fuel_flow1 = getprop("/engines/engine/fuel-flow-pph");
	var fuel_flow2 = getprop("/engines/engine[1]/fuel-flow-pph");
	var alt_prop = "/autopilot/settings/counter-set-altitude-ft";
	aircraft = "777-200ER";
} else if (aircraft == "CRJ700") {
	var fuel_pph = 3600;
	var cruise_mach = 0.84;
	ac_unknown = 0;
	var fuel_flow1 = getprop("/engines/engine/fuel-flow-pph");
	var fuel_flow2 = getprop("/engines/engine[1]/fuel-flow-pph");
	var alt_prop = "/controls/autoflight/altitude-select";
}

var list1 = setlistener("_manne/PHASE", func {
	print("list1 init...");
}, 0, 0);
removelistener(list1);

var list2 = setlistener("_manne/PHASE", func {
	print("list2 init...");
}, 0, 0);
removelistener(list2);

var list3 = setlistener("_manne/PHASE", func {
	print("list3 init...");
}, 0, 0);
removelistener(list3);


###PHASE Listener

list1 = setlistener("/_manne/PHASE", func {

	gui.popupTip("Phase changed to "~getprop("/_manne/PHASE"));

	if (getprop("/_manne/PHASE") == "APPROACH") {

		# TOD und Descent timer beenden
		timer_TOD.stop();
		print("timer_TOD.stop();");

		# play sound
		sound();


		# set ILS frequency
		var dest_runway = getprop("autopilot/route-manager/destination/runway");
		var runways = airportinfo(getprop("autopilot/route-manager/destination/airport")).runways;
		var r = runways[dest_runway];
		if (r != nil and r.ils != nil) {
			setprop("instrumentation/nav/frequencies/selected-mhz", (r.ils.frequency / 100));
			setprop("/sim/messages/copilot", "Setting ILS Frequency for approach!");

			list3 = setlistener("instrumentation/nav/radials/target-radial-deg", func {
				setprop("instrumentation/nav/radials/selected-deg", getprop("instrumentation/nav/radials/target-radial-deg"));
			}, 0, 0);


		}

		# # # fü r ldg light an aus sollte man eine funktion schreiben
		if (aircraft == "737-300") {
			var ll0 = getprop("controls/lighting/landing-lights-fixed-left");
			var ll1 = getprop("controls/lighting/landing-lights-fixed-right");
			var ll2 = getprop("controls/lighting/landing-lights-retract-left");
			var ll3 = getprop("controls/lighting/landing-lights-retract-right");

			if ((ll0 != "true") or(ll1 != "true") or(ll2 != "true") or(ll3 != "true")) {
				setprop("controls/lighting/landing-lights-fixed-left", "true");
				setprop("controls/lighting/landing-lights-fixed-right", "true");
				setprop("controls/lighting/landing-lights-retract-left", "true");
				setprop("controls/lighting/landing-lights-retract-right", "true");
				setprop("/sim/messages/pilot", "Landing lights ... ON");
			}
		}
		if (aircraft == "777-200ER") {
			# # setprop("controls/lighting/landing-light", "true");
			setprop("controls/lighting/landing-lights", "true");
			# # setprop("controls/lighting/landing-light[1]", "true");
			# # setprop("controls/lighting/landing-light[2]", "true");
			setprop("/sim/messages/pilot", "Landing lights ... ON");

			setprop("controls/flight/speedbrake-lever", "2");
			setprop("/sim/messages/copilot", "Speedbrake ... ARMED");
			setprop("autopilot/autobrake/step", "2");
			setprop("/sim/messages/pilot", "Autobrake ... Set to 2");
		}
		if (aircraft == "747-8i") {


		}
		if (aircraft == "A330") {
			setprop("/controls/lighting/landing-lights[1]",1);
			setprop("/controls/lighting/taxi-light-switch",1);
		}		

		# autobrake und speedbrake armed fehlt noch
		
		if (aircraft == "A330") {
			
			#autobrake
			setprop("/controls/autobrake/mode",2);
			setprop("/sim/messages/copilot", "Setting Autobrake to Medium!");
			
		}
		
		

		# final approach: check gear down flaps down speedbrake armed etc
		
		
		timer_approach_to_final.start();
		print("timer_approach_to_final.start");
		
		
		

	} else if (getprop("/_manne/PHASE") == "CLIMB") {

		timer_Climb.stop();
		timer_TOD.start();
		print("timer_Climb.stop();");
		print("timer_TOD.start();");
		
		
		if (aircraft == "A330") {
			setprop("/controls/gear/gear-down","false");
			setprop("/sim/messages/copilot", "Gear up");
			setprop("it-autoflight/input/lat",1);
			setprop("it-autoflight/input/ap1",1);
			setprop("it-autoflight/input/spd-kts",170);	
			setprop("it-autoflight/input/vert",4);
			setprop("/sim/messages/pilot", "Autopilot engaged!");
			
			settimer(func(){
				setprop("it-autoflight/input/spd-kts",190);	
				setprop("/sim/messages/copilot","Setting speed to 190");
				props.setAll("controls/engines/engine", "throttle", 0.6);
				setprop("/sim/messages/copilot","Setting throttle to auto-mode");
			}, 30);
			
			settimer(func(){
				controls.flapsDown(-1);
				setprop("/sim/messages/copilot","Flaps up");
			}, 45);
			
			settimer(func(){
				setprop("it-autoflight/input/spd-kts",230);	
				setprop("/sim/messages/copilot","Setting speed to 230");
			}, 60);
			
			settimer(func(){
				setprop("/controls/lighting/landing-lights[1]",0); # after 10 seconds
				setprop("/sim/messages/copilot","Landing lights off");
				setprop("/controls/lighting/taxi-light-switch",0); # after 10 seconds
				setprop("/sim/messages/copilot","Taxi lights off");
			}, 70);
						
			
						
		}

		
		

		if (aircraft == "737-300") {
			print("listener gestartet");
			list2 = setlistener(alt_prop, func {
				if (getprop("/_manne/PHASE") == "CLIMB") {
					print("listener arbeitet!");
					if (getprop(alt_prop) != getprop("/autopilot/route-manager/cruise/altitude-ft")) {
						setprop(alt_prop, getprop("/autopilot/route-manager/cruise/altitude-ft"));
					}
				}
			}, 0, 0);
		}

		timer_detect_cruise.start();
		print("timer_detect_cruise.start();");

	} else if (getprop("/_manne/PHASE") == "CRUISE") {

		timer_detect_cruise.stop();
		if (aircraft == "737-300") {
			removelistener(list2);
		}

	} else if (getprop("/_manne/PHASE") == "START") {

		if (timer_detect_cruise.isRunning == "true") {timer_detect_cruise.stop();}
		if (timer_Climb.isRunning == "true") {timer_Climb.stop();}
		if (timer_approach_to_final.isRunning == "true") {timer_approach_to_final.stop();}
		if (timer_Touchdown.isRunning == "true") {timer_Touchdown.stop();}
		if (timer_Rollout.isRunning == "true") {timer_Rollout.stop();}
		if (timer_737_altitude_catch.isRunning == "true") {timer_737_altitude_catch.stop();}
		if (timer_TOD.isRunning == "true") {timer_TOD.stop();}
		if (timer_update_properties == "true") {timer_update_properties.stop();}
		if (timer_qnh_setting == "true") {timer_qnh_setting.stop();}


		setprop("/sim/messages/copilot","Copilot is ready for take-off");


		timer_update_properties.start();
		print("timer_update_properties.start();");

		timer_qnh_setting.start();
		print("timer_qnh_setting.start();");

		timer_Climb.start();

	}
	 else if (getprop("/_manne/PHASE") == "FINAL") {

		timer_approach_to_final.stop();
		print("timer_approach_to_final.stop();");
		timer_Touchdown.start();
		print("timer_Touchdown.start();");
		
		}
	
	 else if (getprop("/_manne/PHASE") == "TOUCHDOWN") {

		timer_Touchdown.stop();
		print("timer_Touchdown.stop();");
		
			
		setprop("/controls/gear/brake-left",1);
		setprop("/controls/gear/brake-right",1);
		setprop("/sim/messages/pilot","Slowing Down");
		props.setAll("controls/engines/engine", "throttle", 0); # Throttle Idle

		settimer(func(){
			#Reverser an
			#print("Reverser an");
			#setprop("/it-autoflight/output/athr",0);
			systems.toggleFastRevThrust();
			setprop("/sim/messages/pilot","Reverser!");
		}, 1.5);
		
		
		timer_Rollout.start();
		
		}
		
	 else if (getprop("/_manne/PHASE") == "TAXI_TO_GATE") {

		timer_Rollout.stop();
		print("timer_Touchdown.stop();");
		
		if (getprop("/controls/engines/engine/reverser") == 1){
			
			systems.toggleFastRevThrust();
			setprop("/sim/messages/pilot","Reverser off");
			
		}
		#Reverser aus

		setprop("/controls/gear/brake-left",0);
		setprop("/controls/gear/brake-right",0);
	
		if (getprop("/_manne/_autostop") == 1 ) {
			setprop("/controls/gear/brake-parking",1);
			setprop("/sim/messages/copilot","Setting Parking Brake");
		}
			
		else {
			setprop("/it-autoflight/output/ap1",0);
			setprop("/it-autoflight/output/ap2",0);
			setprop("/sim/messages/copilot","Autopilot disengaged");
		}
		
		controls.flapsDown(-1);
		controls.flapsDown(-1);
		controls.flapsDown(-1);
		controls.flapsDown(-1);
		controls.flapsDown(-1);
		setprop("/sim/messages/copilot","Flaps up");
		
		
		settimer(func(){
			setprop("/controls/lighting/landing-lights[1]",0); # after 10 seconds
			setprop("/controls/lighting/strobe",0);
			setprop("/sim/messages/copilot","Landing Lights off");
			setprop("/sim/messages/copilot","Strobes off");
		}, 10);
					
		
		
		settimer(func(){
			setprop("/controls/APU/master","true"); # after 15 seconds
			setprop("/controls/APU/start","true");
		    setprop("/sim/messages/copilot","A P U started");
		}, 2);
		
		
		settimer(func(){
		    setprop("_manne/PHASE","START");
			setprop("_manne/_autostop",0);
		}, 2);
		
		
		}

}, 0, 0);





# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# create timer with 10 second interval
var timer_ias_mach = maketimer(5.0, func {

	var mach = getprop("/instrumentation/airspeed-indicator/indicated-mach");
	var kts = getprop("/instrumentation/airspeed-indicator/indicated-speed-kt");

	if (mach >= (cruise_mach - 0.005) and kts < 325 and getprop(getprop("_manne/cfg/kts-mach-selector")) == 0) {

		if (aircraft =="A330") {
	
			setprop(getprop("/_manne/cfg/kts-mach-selector"), 1);
			setprop(getprop("/_manne/cfg/mach"), cruise_mach);
			setprop("/sim/messages/copilot", "Switching selector to cruising mach number!");
			
		}

		else if ((aircraft == "747-8i"
				or aircraft == "777-200ER") and getprop("/instrumentation/afds/inputs/ias-mach-selected") == 0) {

			setprop("/instrumentation/afds/inputs/ias-mach-selected", 1);
			setprop("/autopilot/settings/target-speed-mach", cruise_mach);
			setprop("/sim/messages/copilot", "Switching selector to cruising mach number!");

		} else if (aircraft == "737-300"
			and getprop("/autopilot/internal/SPD-IAS") == 1) {
			setprop("/autopilot/internal/SPD-IAS", 0);
			setprop("/autopilot/internal/SPD-MACH", 1);
			setprop("/autopilot/settings/target-speed-mach", cruise_mach);
			setprop("/sim/messages/copilot", "Switching selector to cruising mach number!");
		} else if (aircraft == "CRJ700"
			and getprop("/controls/autoflight/speed-mode") == 0) {
			setprop("/controls/autoflight/speed-mode", 1);
			setprop("/controls/autoflight/mach-select", cruise_mach);
			setprop("/sim/messages/copilot", "Switching selector to cruising mach number!");
		} else if (aircraft == "737-800YV"
			and getprop("/it-autoflight/input/kts-mach") == 0) {
			setprop("/it-autoflight/input/kts-mach", 1);
			setprop("/it-autoflight/input/spd-mach", cruise_mach);
			setprop("/sim/messages/copilot", "Switching selector to cruising mach number!");
		}

	} else if (kts > 325 and getprop(getprop("_manne/cfg/kts-mach-selector")) == 1) {

		if ((aircraft == "747-8i"
				or aircraft == "777-200ER") and getprop("/instrumentation/afds/inputs/ias-mach-selected") == 1) {
			setprop("/instrumentation/afds/inputs/ias-mach-selected", 0);
			setprop("/autopilot/settings/target-speed-kt", 320);
			setprop("/sim/messages/copilot", "Switching selector to IAS!");
		} else if (aircraft == "737-300"
			and getprop("/autopilot/internal/SPD-MACH") == 1) {
			setprop("/autopilot/internal/SPD-IAS", 1);
			setprop("/autopilot/internal/SPD-MACH", 0);
			setprop("/autopilot/settings/target-speed-kt", 320);
			setprop("/sim/messages/copilot", "Switching selector to IAS!");
		} else if (aircraft == "CRJ700"
			and getprop("/controls/autoflight/speed-mode") == 1) {
			setprop("/controls/autoflight/speed-mode", 0);
			setprop("/controls/autoflight/speed-select", 320);
			setprop("/sim/messages/copilot", "Switching selector to IAS!");
		} else if (aircraft == "737-800YV"
			and getprop("/it-autoflight/input/kts-mach") == 1) {
			setprop("/it-autoflight/input/kts-mach", 0);
			setprop("/it-autoflight/input/spd-kts", 320);
			setprop("/sim/messages/copilot", "Switching selector to IAS!");
		}
		else {
			setprop(getprop("/_manne/cfg/kts-mach-selector"), 0);
			setprop(getprop("/_manne/cfg/kts"), 280);
			setprop("/sim/messages/copilot", "Switching selector to descent speed!");
		}
			
	}

});



# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # timer_update_properties # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

var timer_update_properties = maketimer(3.0, func {

	# Calculate Range
	var fuelburn = getprop("_manne/fuelburn_p_h");
	# lbs per hour
	var gs = 480;
	var total_lbs = getprop("/consumables/fuel/total-fuel-lbs");
	var distance_flightplan = getprop("/autopilot/route-manager/distance-remaining-nm");

	var duration_possible = total_lbs / fuelburn;

	var duration_possible_h = math.floor(duration_possible);
	var duration_possible_m = (duration_possible - duration_possible_h) * 60;

	var distance_possible = duration_possible * gs;

	var duration_flightplan = distance_flightplan / gs;
	var duration_flightplan_h = math.floor(duration_flightplan);
	var duration_flightplan_m = (duration_flightplan - duration_flightplan_h) * 60;

	var MEZ_time_h = getprop("/sim/time/real/hour");
	var MEZ_time_m = getprop("/sim/time/real/minute");

	var arrival_time_h = MEZ_time_h + duration_flightplan_h;
	var arrival_time_m = MEZ_time_m + duration_flightplan_m;

	if (arrival_time_m > 59) {
		arrival_time_m = arrival_time_m - 60;
		arrival_time_h = arrival_time_h + 1;
	}

	if (arrival_time_h > 23) {
		arrival_time_h = arrival_time_h - 24;
	}

	var soll_lbs = duration_flightplan * fuelburn;

	var dest_name = getprop("/autopilot/route-manager/destination/name");

	setprop("_manne/fuel_needed", soll_lbs);
	setprop("_manne/fuel_on_board", total_lbs);
	setprop("_manne/arrival_MEZ", sprintf("%02d:%02d", arrival_time_h, arrival_time_m, ));
	setprop("_manne/range", distance_possible);
	setprop("_manne/distance", math.floor(getprop("/autopilot/route-manager/distance-remaining-nm")));
	setprop("_manne/metar_dest", getprop("/environment/metar[10]/data"));
	setprop("_manne/metar_local", getprop("/environment/metar/data"));
	setprop("_manne/mach", getprop("/instrumentation/airspeed-indicator/indicated-mach"));
	setprop("_manne/kts", math.floor(getprop("/instrumentation/airspeed-indicator/indicated-speed-kt")));
	setprop("_manne/gs", math.floor(getprop("/velocities/groundspeed-kt")));
	setprop("_manne/altitude", math.floor(getprop("/instrumentation/altimeter/indicated-altitude-ft")));


	# # # fuel flow

	if (aircraft == "747-8i") {
		fuel_flow1 = getprop("/engines/engine/fuel-flow-gph");
		fuel_flow2 = getprop("/engines/engine[1]/fuel-flow-gph");
		fuel_flow3 = getprop("/engines/engine[2]/fuel-flow-gph");
		fuel_flow4 = getprop("/engines/engine[3]/fuel-flow-gph");

		setprop("_manne/fuel_flow_pph", (fuel_flow1 + fuel_flow2 + fuel_flow3 + fuel_flow4) * 8.345);

	}

	else  {
		fuel_flow1 = getprop("/engines/engine/fuel-flow_pph");
		fuel_flow2 = getprop("/engines/engine[1]/fuel-flow_pph");

		setprop("_manne/fuel_flow_pph", fuel_flow1 + fuel_flow2);

	}






});


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # timer_737_altitude_catch # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

var timer_737_altitude_catch = maketimer(3.0, func {


	var altitude_ist = getprop("/instrumentation/altimeter/indicated-altitude-ft");
	var altitude_soll = getprop(alt_prop);
	var altitude_alt_mode = getprop("/autopilot/internal/VNAV-ALT");
	var altitude_vs_mode = getprop("/autopilot/internal/VNAV-VS");
	setprop("/sim/messages/copilot", altitude_ist - altitude_soll);
	## only for debug

	if (((altitude_ist - altitude_soll < 1000) and(altitude_ist - altitude_soll > -1000)) and(altitude_alt_mode == 0) and(altitude_vs_mode == 1) and(altitude_ist > 4000)) {

		setprop("/autopilot/internal/VNAV-ALT", 1);
		setprop("/autopilot/internal/VNAV-VS", 0);
		setprop("/autopilot/settings/vertical-speed-fpm", 0);
		setprop("/sim/messages/copilot", "Switching autopilot to ALT-Mode!");

	}

});

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # timer_approach_to_final # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

var timer_approach_to_final = maketimer(10.0, func {

	if (getprop("/_manne/distance") > 12 and getprop("/_manne/distance") <= 15 and getprop(getprop("/_manne/cfg/kts")) != 190) {
		
		setprop(getprop("/_manne/cfg/kts"),190);
		setprop("/sim/messages/pilot", "Reducing to 190");	
		
		settimer(func(){
			controls.flapsDown(1);
			setprop("/sim/messages/pilot", "FLAPS 1");
		}, 5);

		
	}
	if (getprop("/_manne/distance") > 8 and getprop("/_manne/distance") <= 12 and getprop(getprop("/_manne/cfg/kts")) != 180) {
		
		setprop(getprop("/_manne/cfg/kts"),180);
		setprop("/sim/messages/pilot", "Reducing to 180");

		setprop(getprop("/_manne/cfg/altitude"),getprop("/autopilot/route-manager/destination/field-elevation-ft") + 2000);
		setprop("/it-autoflight/input/vert", 1);
		setprop(getprop("/_manne/cfg/vs"), -1000);		
		setprop("/sim/messages/pilot", "Descending to Glide Slope");
		controls.flapsDown(1);
		setprop("/sim/messages/pilot", "FLAPS 2");
		
	}
	if (getprop("/_manne/distance") > 3 and getprop("/_manne/distance") <=8 and getprop(getprop("/_manne/cfg/kts")) != 150) {
		
		setprop(getprop("/_manne/cfg/kts"),150);
		setprop("/sim/messages/pilot", "Reducing to 150");
		setprop("/controls/gear/gear-down","true");
		setprop("/sim/messages/copilot", "Gear down");
		setprop("/it-autoflight/output/loc-armed",1);
		setprop("/it-autoflight/output/appr-armed",1);
		setprop("/sim/messages/copilot", "ILS armed");
		controls.flapsDown(1);
		setprop("/sim/messages/pilot", "FLAPS 3");
		
	}	
	if (getprop("/_manne/distance") >1 and getprop("/_manne/distance") <= 3 and getprop(getprop("/_manne/cfg/kts")) != 140) {
		
		setprop(getprop("/_manne/cfg/kts"),140);
		setprop("/sim/messages/pilot", "Reducing to 140");
		
			controls.flapsDown(1);
			setprop("/sim/messages/pilot", "FLAPS FULL");
			setprop("/_manne/PHASE", "FINAL");


	}
	

});

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # timer_qnh_setting # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

var timer_qnh_setting = maketimer(10.0, func {
	var ist_pressure_setting = getprop("/instrumentation/altimeter/setting-inhg");
	var altitude_ist = getprop("/instrumentation/altimeter/indicated-altitude-ft");
	var trams_alt = getprop("_manne/trans_alt");
	var distance = getprop("_manne/distance");
	var route_active = getprop("/autopilot/route-manager/active");

	if (distance > 100 or route_active == 0) {
		var soll_pressure_setting = getprop("/environment/metar/pressure-inhg");
		var metar_station = getprop("/environment/metar/station-id");
		var elevation = getprop("/environment/metar/station-elevation-ft");
	} else if (route_active == 1) {
		var soll_pressure_setting = getprop("/environment/metar[10]/pressure-inhg");
		var metar_station = getprop("/environment/metar[10]/station-id");
		var elevation = getprop("/environment/metar[10]/station-elevation-ft");
	}

	# # # get METAR of destination # # #
	if (getprop("/autopilot/route-manager/destination/airport") != getprop("/environment/metar[10]/station-id")) {
		setprop("/environment/metar[10]/station-id", getprop("/autopilot/route-manager/destination/airport"));
		setprop("/environment/metar[10]/time-to-live", 0);
		setprop("/sim/messages/pilot", "Requesting METAR information at destination....");
	}
	# # # set METAR of destination / or local value, depending on distance # # #
	else if (ist_pressure_setting != soll_pressure_setting and altitude_ist < trams_alt) {
		setprop("/instrumentation/altimeter/setting-inhg", soll_pressure_setting);
		setprop("/sim/messages/pilot", sprintf("Setting QNH to %d. %s elevation is: %d feet.", math.round(getprop("/instrumentation/altimeter/setting-hpa")), metar_station, elevation));

	}

	# # # set Altimeter to 1013 hpa # # #
	else if (ist_pressure_setting != 29.92 and altitude_ist > trams_alt) {

		setprop("/instrumentation/altimeter/setting-inhg", 29.92);
		setprop("/sim/messages/pilot", "Setting Altimeter to 1013");

	}


});

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # timer_descent # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #


var timer_TOD = maketimer(3.0, func {

	var distance = getprop("/_manne/distance");

	# # # muss nur nach Ä nderung der DEST berechnet werden.# # LISTENER
	var approach_elevation = getprop("/autopilot/route-manager/destination/field-elevation-ft") + 4000;
	setprop("/_manne/approach_elevation", approach_elevation);

	var TOD_distance = math.ceil(((getprop("_manne/altitude") - approach_elevation) / 100) / 3) + 15;

	setprop("/_manne/TOD_distance", TOD_distance);

	# # # descent rate calaculations # # #

	var descent_rate = getprop("/velocities/groundspeed-kt") * 5.2;
	descent_rate = math.ceil(descent_rate / 200) * 200;

	setprop("_manne/descent_rate", math.floor(descent_rate));

	if (getprop("_manne/PHASE") == "CRUISE" and TOD_distance >= distance) {
		
		setprop("/_manne/PHASE", "DESCENT");
		setprop("/sim/messages/pilot", "Starting descent!");

		if (aircraft == "737-300") {
			setprop(alt_prop, approach_elevation);
			setprop("/autopilot/settings/vertical-speed-fpm", -1 * descent_rate);
			setprop("/autopilot/internal/VNAV-ALT", 0);
			setprop("/autopilot/internal/VNAV-VS", 1);
		}

		else if (aircraft == "747-8i") {
			setprop(alt_prop, approach_elevation);
			setprop("/instrumentation/afds/inputs/vertical-index", 2);
			setprop("/autopilot/settings/vertical-speed-fpm", -1 * descent_rate);
			setprop("/instrumentation/afds/settings/flch-mode", 1);
			# # setprop("/autopilot/internal/VNAV-ALT", 0);
			# # setprop("/autopilot/internal/VNAV-VS", 1);
		}
		else if (aircraft == "777-200ER") {
			setprop(alt_prop, approach_elevation);
			setprop("/instrumentation/afds/inputs/vertical-index", 2);
			setprop("/autopilot/settings/vertical-speed-fpm", -1 * descent_rate);

		}
		else if (aircraft == "CRJ700") {
			setprop(alt_prop, approach_elevation);
			setprop("/controls/autoflight/vertical-mode", 1);
			setprop("/controls/autoflight/vertical-speed-select", -1 * descent_rate);

		}
		else if (aircraft == "737-800YV") {
			setprop(alt_prop, approach_elevation);
			setprop("/it-autoflight/input/vert", 1);
			setprop("/it-autoflight/input/vs", -1 * descent_rate);

		}
		else {
			setprop(getprop("/_manne/cfg/altitude"), approach_elevation);
			setprop("/it-autoflight/input/vert", 1);
			setprop(getprop("/_manne/cfg/vs"), -1 * descent_rate);
			print("debug!");
		}
		
	}
	if (getprop("_manne/PHASE") == "DESCENT"
		and TOD_distance - distance <= -1 and - 1 * descent_rate != getprop(getprop("/_manne/cfg/vs"))) {
		setprop("/sim/messages/pilot", "Adjusting rate of descent!");

		if (aircraft == "CRJ700") {
			setprop("/controls/autoflight/vertical-speed-select", -1 * descent_rate);
		} else if (aircraft == "737-800YV") {
			setprop("/it-autoflight/input/vs", -1 * descent_rate);
		} else {
			setprop(getprop("/_manne/cfg/vs"), -1 * descent_rate);
		}
	}

	if (getprop("_manne/PHASE") == "DESCENT"
		and getprop("_manne/altitude") < 13000 and getprop(getprop("/_manne/cfg/kts")) > 250) {

		if (aircraft == "737-800YV") {
			setprop("/it-autoflight/input/speed-kts", 240);
		} else {
			setprop(getprop("/_manne/cfg/kts"), 240);
		}
		setprop("/sim/messages/pilot", "Reducing speed to 240!");
	}

	var altitude_ist = getprop("/instrumentation/altimeter/indicated-altitude-ft");
	#print(getprop("/_manne/cfg/altitude"));
	var altitude_soll = getprop(getprop("/_manne/cfg/altitude"));
	#print (altitude_soll);




	if (((altitude_ist - altitude_soll < 1000) and(altitude_ist - altitude_soll > -1000)) and(getprop("/_manne/PHASE") == "DESCENT")) {
		setprop("/_manne/PHASE", "APPROACH");
		setprop("/sim/messages/copilot", sprintf("APPROACH! We are %d miles out.", getprop("/_manne/distance")));
	}


});



# # # # # # # # # # # # # # # # # # detecting climb timer # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

var timer_Climb = maketimer(3.0, func {

	if (getprop("/velocities/airspeed-kt") > 140 and getprop("/position/gear-agl-ft") > 150 ) {
		setprop("/_manne/PHASE", "CLIMB");
	}

});

# # # # # # # # # # # # # # # # # # detecting slow after bremsen # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

var timer_Rollout = maketimer(0.5, func {

	if (getprop("/velocities/groundspeed-kt") < 30) {
		setprop("/_manne/PHASE", "TAXI_TO_GATE");
	}
###PUPS
});

# # # # # # # # # # # # # # # # # # detecting touchdown timer # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

var timer_Touchdown = maketimer(0.5, func {

	#print ("huhu");
	#print(getprop("/fdm/jsbsim/gear/wow"));
	
	if (getprop("/fdm/jsbsim/gear/wow") == 1) {
			setprop("/sim/messages/pilot","Touchdown!");	
			setprop("/_manne/PHASE","TOUCHDOWN");	
	}

});

# # # # # # # # # # # # # # # # # # detecting cruise and watching climb timer # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

var timer_detect_cruise = maketimer(3.0, func {

	var altitude_ist = getprop("/instrumentation/altimeter/indicated-altitude-ft");
	var altitude_soll = getprop(getprop("/_manne/cfg/altitude"));

	print(altitude_soll - altitude_ist);

	if (altitude_ist > 10000 and getprop(getprop("/_manne/cfg/kts")) <= 250) {
		if (aircraft == "737-800YV") {
			setprop("/it-autoflight/input/speed-kts", 320);
		} else {
			setprop(getprop("/_manne/cfg/kts"), 320);
		}
		setprop("/sim/messages/pilot", "Setting speed to 320 knots!");
	}

	if (altitude_soll - altitude_ist < 1000) {
		setprop("/_manne/PHASE", "CRUISE");
	}

});


# # # # # # # # # # # # # # # # # # # # start the timers(with 10 second inverval) # # # # # # # # # # # # # # # # # # # # # #
if (ac_unknown == 0) {
	timer_ias_mach.start();
	print("	timer_ias_mach.start();");
}

if (aircraft == "737-300") {
	timer_737_altitude_catch.start();
}

setprop("_manne/fuelburn_p_h", fuel_pph);
setprop("_manne/trans_alt", 7000);
setprop("_manne/PHASE", "START");


print("Mannes Nasal Script....loaded!");



# # # # # # # # # # # # # # # # # # # # functions # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

var sound = func() {
	var hash = {
		"url": "http://192.168.1.39/config/xmlapi/runprogram.cgi?program_id=14554",
		"targetnode": "/server-response"
	};
	var params = props.Node.new(hash);
	fgcommand("xmlhttprequest", params);
};
