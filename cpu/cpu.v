module CPU(clk,reset,interrupt,T1,T2,PC,MAR,IR,uMA,A,B,ALU,R0,R1,R2,R3,LDR,LDIR,BUS,OUT);
	input clk,reset,interrupt;
	output T1,T2,PC,MAR,IR,uMA,A,B,ALU,R0,R1,R2,R3,LDR,LDIR,BUS,OUT;
	reg[7:0] IN;
	reg[7:0] MEM0,MEM1,MEM2,MEM3,MEM4,MEM5,MEM6,MEM7; //��������
	reg[7:0] R0,R1,R2,R3,ALU,A,B,PC,BUS,MAR,IR,OUT;
	// reg[7:0] IN	�����豸
	// reg[7:0] OUT ����豸
	reg[2:0] IOM;  // 3λ��д�����ֶ�
	reg[1:0] S;  // 2λALU�����ֶ�
	reg[2:0] LDXXX,XXX_B,C; // A��B��C�����ֶ�
	reg[5:0] uMA; // 6λ΢��ַ�ֶ�
	//T1ʱ��ֱ��XXX_B������LDXXX�����ź�, T2ʱ�̸���LDXXX�ź� ��bus������
	reg LDA,LDB,LDR,LDPC,LDOUT,LDMAR,LDIR,INC_PC; // ΢�����ź�
	reg P1,P2,P3,P4,P5,STI,CLI;
	reg T1;
	wire T2;
	
	//����ʱ��T1 T2����ʼ�ڴ��еĻ���ָ��
	always @(posedge clk)
	begin
		if(reset)
			begin
				T1 <= 1'b0;
				//�ڴ��ʼ��ֵ���������ָ�MEM----------------		
				IN <= 8'd9;//ΪIN��ֵ		
				MEM0 <= 8'b00000000; //��IN����ֵ��00�Ĵ���
				MEM1 <= 8'b00100100; // 00 -> 01�Ĵ�������
				MEM2 <= 8'b00010000; // ���00
				MEM3 <= 8'b00010001; // ���01
				//MEM1 = 
				//MEM2 = 
			end
		else
			T1 <= ~T1;
	end

	assign T2=~T1;
	
	//T1 ����΢������ֶ�
	always @(posedge T1)
	begin
		if(reset)
			uMA <= 6'b000000;
		else
			begin
				case(uMA)
						6'h00:
							begin
								S <= 2'b00;
								XXX_B <= 3'b101;
								LDXXX <= 3'b000;
								C <= 3'b000;
								INC_PC <= 1'b0;
								uMA <= 6'h01;
							end
						6'h01:
							begin
								S <= 2'b00;
								XXX_B <= 3'b000;
								LDXXX <= 3'b000;
								C <= 3'b001; //P<1>�ж�
								INC_PC <= 1'b0;
								if(interrupt)
									uMA <= 6'h35;//�жϵ�ַ�����޸�
								else 
									uMA <= 6'h02;
							end
						6'h02:
							begin
								S <= 2'b00;
								XXX_B <= 3'b011;
								LDXXX <= 3'b101;
								C <= 3'b000;
								INC_PC <= 1'b1;
								uMA <= 6'h03;
							end
						6'h03:
							begin
								S <= 2'b00;
								XXX_B <= 3'b110;
								LDXXX <= 3'b110;
								C <= 3'b000;
								INC_PC <= 1'b0;
								uMA <= 6'h04;
							end
						6'h04:
							begin
								S <= 2'b00;
								XXX_B <= 3'b000;
								LDXXX <= 3'b000;
								C <= 3'b010; //P<2>�ж�
								INC_PC <= 1'b0;
								case({IR[7],IR[6],IR[5],IR[4]})
									4'b0000:
										uMA <= 6'h05;
									4'b0001:
										uMA <= 6'h06;
									4'b0010:
										uMA <= 6'h07;
								endcase
							end
						6'h05:
							begin
								S <= 2'b00;
								XXX_B <= 3'b111;
								LDXXX <= 3'b011;
								C <= 3'b000;
								INC_PC <= 1'b0;
								uMA <= 6'h06;
							end
						6'h06:
							begin
								S <= 2'b00;
								XXX_B <= 3'b010;
								LDXXX <= 3'b100;
								C <= 3'b000;
								INC_PC <= 1'b0;
								uMA <= 6'h07;
							end
						6'h07:
							begin
								S <= 2'b00;
								XXX_B <= 3'b010;
								LDXXX <= 3'b011;
								C <= 3'b000;
								INC_PC <= 1'b0;
								uMA <= 6'h00;
							end
				endcase
			end
	end
	
	//����ÿ�ֶεĿ����ź�
	always @(S or LDXXX or XXX_B or C)
	begin	
		//ALU�������
		case(S)
				2'b00:
					begin
						ALU <= ALU;
					end
				2'b01:
					begin
						ALU <= A + B;
					end	
				2'b10:
					begin
						ALU <= A && B;
					end	
				//2'b11:
		endcase
		// A�ֶο��� LDXX
		case(LDXXX)
				3'b000:
					begin
						{LDA,LDB,LDR,LDOUT,LDMAR,LDIR,LDPC} <= 7'b0000000;
					end
				3'b001:
					begin
						{LDA,LDB,LDR,LDOUT,LDMAR,LDIR,LDPC} <= 7'b1000000;
					end
				3'b010:
					begin
						{LDA,LDB,LDR,LDOUT,LDMAR,LDIR,LDPC} <= 7'b0100000;
					end
				3'b011:
					begin
						{LDA,LDB,LDR,LDOUT,LDMAR,LDIR,LDPC} <= 7'b0010000;
					end
				3'b100:
					begin
						{LDA,LDB,LDR,LDOUT,LDMAR,LDIR,LDPC} <= 7'b0001000;
					end
				3'b101:
					begin
						{LDA,LDB,LDR,LDOUT,LDMAR,LDIR,LDPC} <= 7'b0000100;
					end
				3'b110:
					begin
						{LDA,LDB,LDR,LDOUT,LDMAR,LDIR,LDPC} <= 7'b0000010;
					end
				3'b111:
					begin
						{LDA,LDB,LDR,LDOUT,LDMAR,LDIR,LDPC} <= 7'b0000001;
					end
		endcase
		// B�ֶο��� XX_B
		case(XXX_B)
				3'b000:
					begin
						BUS <= BUS;
					end
				3'b001:
					begin
						BUS <= ALU;
					end
				3'b010:
					begin
						case({IR[1],IR[0]})
							2'b00:
								BUS <= R0;
							2'b01:
								BUS <= R1;
							2'b10:
								BUS <= R2;
							2'b11:
								BUS <= R3;
						endcase
					end
				3'b011:
					begin
						BUS <= PC;
					end
				3'b100:
					begin
						STI <= 1'b1;
						CLI <= 1'b0;
					end
				3'b101:
					begin
						STI <= 1'b0;
						CLI <= 1'b1;
					end
				3'b110:
				begin
					case(MAR)
						8'h00:
							BUS <= MEM0;
						8'h01:
							BUS <= MEM1;
						8'h02:
							BUS <= MEM2;
						8'h03:
							BUS <= MEM3;
						/*
						8'h04:
							BUS <= MEM4;
						8'h05:
							BUS <= MEM5;
						8'h06:
							BUS <= MEM6;
						8'h07:
							BUS <= MEM7;
						//8'h08:
						*/
					endcase
				end
				3'b111:
					BUS <= IN;
		endcase
		/*
		// C�ֶο��� 
		case(C)
				3'b000:
					begin
						//NOP
					end
				3'b001:
					begin
						
					end
				3'b010:
					begin
						
					end
				3'b011:
					begin
						
					end
				3'b100:
					begin
						
					end
				3'b101:
					begin
						
					end
				3'b110:
					begin
						
					end
		endcase
		*/
	end
	//���ݿ����źţ���������ֵ(�漰��PC�Ĳ���)
	always @(posedge T2)
	begin
		if(LDA)
			A <= BUS;
		if(LDB)
			B <= BUS;
		if(LDR)
		begin
			case({IR[3],IR[2]})
						2'b00:
							R0 <= BUS;
						2'b01:
							R1 <= BUS;
						2'b10:
							R2 <= BUS;
						2'b11:
							R3 <= BUS;
			endcase
		end
		if(LDOUT)
			OUT <= BUS;
		if(LDMAR)
			MAR <= BUS;
		if(LDIR)
			IR <= BUS;
		if(INC_PC)
			PC <= PC + 8'h01;
		if(LDPC)
			PC <= BUS;
	end
endmodule
