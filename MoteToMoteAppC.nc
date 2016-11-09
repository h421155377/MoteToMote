configuration MoteToMoteAppC{
}
implementation{
	components MoteToMoteC as App;
	components MainC;
	components LedsC;
	
	
	App.Boot -> MainC;
	App.Leds -> LedsC;
	
	
	components ActiveMessageC;
	components new AMSenderC(AM_RADIO);
	components new AMReceiverC(AM_RADIO);
	components new TimerMilliC() as Timer0;
	components new TimerMilliC() as Timer1;
	components new TimerMilliC() as Timer2;
	
	
	App.Packet -> AMSenderC;
	App.AMSend -> AMSenderC;
	App.AMControl -> ActiveMessageC;
	App.Receive -> AMReceiverC;
	App.Timer0 -> Timer0;
	App.Timer1 -> Timer1;
	App.Timer2 -> Timer2;
	
	
	
}
