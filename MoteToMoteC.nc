#include "MoteToMote.h"
module MoteToMoteC
{
	uses
	{
		interface Leds;
		interface Boot;
		interface Timer<TMilli> as Timer0;
		interface Timer<TMilli> as Timer1;
		interface Timer<TMilli> as Timer2;
		
	}
	
	uses
	{
		interface Packet;
		interface AMPacket;
		interface AMSend;
		interface SplitControl as AMControl;
		interface Receive;
	}
}
implementation
{
	bool _radioBusy	= FALSE;
	message_t _packet;
	bool _localState = FALSE;
	bool _token = FALSE;
	uint16_t _NodeId = 0;
	uint16_t _DeviceId = 0;
	
	


	
	void init(uint8_t var)
	{
			if(_radioBusy == FALSE)
			{
				MoteToMoteMsg_t* msg = call Packet.getPayload(& _packet, sizeof(MoteToMoteMsg_t));
				msg -> NodeId = TOS_NODE_ID;
				msg -> Data = (uint8_t) var;
				msg -> Token =(uint8_t) 1;
			
				//send message
				if(call AMSend.send(AM_BROADCAST_ADDR, & _packet, sizeof(MoteToMoteMsg_t)) == SUCCESS)
				{
					_radioBusy = TRUE;
				}
			}
	}
	
	void stendToken(uint16_t var)
	{
			if(_radioBusy == FALSE)
			{
				MoteToMoteMsg_t* msg = call Packet.getPayload(& _packet, sizeof(MoteToMoteMsg_t));
				if(TOS_NODE_ID == 3)
				{
					msg -> NodeId = 1;
				}
				else
				{
					msg -> NodeId = TOS_NODE_ID + 1;
				}
				msg -> NodeId = TOS_NODE_ID+1;
				msg -> Data = (uint8_t) 0;
				msg -> Token =(uint8_t) 1;
			
				//send message
				if(call AMSend.send(AM_BROADCAST_ADDR, & _packet, sizeof(MoteToMoteMsg_t)) == SUCCESS)
				{
					_radioBusy = TRUE;
					call Leds.led2Off();
				}
			}
	}
	

	event void AMSend.sendDone(message_t *msg, error_t error)
	{
		if(msg == &_packet)
		{
			_radioBusy = FALSE;
		}
	}

	event void AMControl.stopDone(error_t error){
		// TODO Auto-generated method stub
	}

	

	event void AMControl.startDone(error_t error)
	{
		if (error == SUCCESS)
		{
			call Leds.led0On();
		}
		else
		{
			call AMControl.start();
		}
	}

	event void Timer0.fired(){
		if(_localState == FALSE)
		{
			_localState = TRUE;
			init((uint8_t) 0);
		}
		else if(_localState == TRUE)
		{
			_localState = FALSE;
			init((uint8_t) 1);
		}
	}

	event void Timer1.fired(){
		//call Leds.led2Toggle();
		call Leds.led2On();
		
	}

	event void Timer2.fired(){
				stendToken(2);

	}
	
	event message_t * Receive.receive(message_t *msg, void *payload, uint8_t len){
		if(len == sizeof(MoteToMoteMsg_t))
		{
			MoteToMoteMsg_t * incomingPacket = (MoteToMoteMsg_t*) payload; 
			
			uint8_t data = incomingPacket-> Data;
			uint16_t localId = incomingPacket-> NodeId;
			uint8_t getToken = incomingPacket-> Token;
			
			if(getToken == 1 && localId == _DeviceId)
			{
				if(localId > 0)
				{
					uint32_t  i = 5;

					call Leds.led2On();
					
					
					_NodeId = _DeviceId + 1;
					
					if(_NodeId == 3)
					{
						_NodeId =1;
					}
					stendToken(_NodeId);
				}
				
			}

			
			
			
			/**
			if(getToken == 0)
			{

				call Leds.led2On();
			}
			if (data == 0)
			{
				call Leds.led2Off();
			}
			**/

				
			
		}
			
		return msg;
	}
	
	
	
	
	event void Boot.booted()
	{
		//call Timer0.startPeriodic(500);
		_DeviceId = TOS_NODE_ID;
		//call Timer2.startPeriodic(500);
		
		
		call AMControl.start();
	}
}
\ No newline at end of file
