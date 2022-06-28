`define NUM_BITS 6 // Try 1, 2, 3, 4, 5,6
module MUX(out,a,selection);
   input [3:0] a;input [1:0] selection;output out;
   wire s0, s1, xx0, xx1, xx2, xx3;
   not n1(s1, selection[1]);
   not n2(s0, selection[0]);
   and a1(xx0, a[0], s0, s1);
   and a2(xx1, a[1], selection[0], s1);
   and a3(xx2, a[2], s0, selection[1]);
   and a4(xx3, a[3], selection[0], selection[1]);
   or o1(out, xx0, xx1, xx2, xx3);
endmodule

module MUX2(out,a0,a1,a2,a3,selection);
   input a0;input a1;input a2;input a3;input [1:0] selection;output out;
   wire s0, s1, xx0, xx1, xx2, xx3;
   not n1(s1, selection[1]);
   not n2(s0, selection[0]);
   and a1(xx0, a0, s0, s1);
   and a2(xx1, a1, selection[0], s1);
   and a3(xx2, a2, s0, selection[1]);
   and a4(xx3, a3, selection[0], selection[1]);
   or o1(out, xx0, xx1, xx2, xx3);
endmodule

module quadruple_MUX(cout,carry,in1,in2,select1,select,d,ins);
   parameter N = `NUM_BITS;
   output [N-1:0] cout;output carry, ot;output ca;
   input [N-1:0]cin1;input d;input [N-1:0]cin2;input [N-1:0]cin3;input [N-1:0]cin4;input [N-1:0]cin5;input [N-1:0]in1;input [N-1:0]in2;input [1:0] select1;input [1:0] select;
   wire [N:0] c;assign c[0]=d;input ins;
   generate
   genvar i;
   for(i=0;i<N;i=i+1)begin
      arithmetic_circuit l2(cin5[i],in2[i],select); 
      full_adder f1(cin1[i],c[i+1],in1[i],cin5[i],c[i]); 
      logic_circuit l1(cin2[i],in1[i],in2[i],select);
   end

   for(i=1;i<N;i=i+1)begin
     buf(cin3[N-1],ins);
     D_FlipFlop f1(cin3[N-i-1],in1[N-i]); //right shift 
   end

   full_adder f1(ot,carry,in1[N-1],cin5[N-1],c[N-1]);  
   for(i=0;i<N;i=i+1)
   begin 
      MUX2 m1(cout[i],cin1[i],cin2[i],cin3[i],cin4[i],select1);
   end
   endgenerate
endmodule

module logic_circuit(out, A,b, selections);
   input  A;input  b;output out;input [1:0] selections;
   wire [3:0] MUX1;
   and (MUX1[0],A,b); 
   or(MUX1[1],A,b); 
   xor(MUX1[2],A,b);
   not(MUX1[3],A);
   MUX m1(out, MUX1, selections);
endmodule

module arithmetic_circuit(final, b, selections);
   output final;
   input  b;input [3:0] MUX1;input [1:0] selections;
   buf b1(MUX1[0],b);
   not n1(MUX1[1],b);
   assign MUX1[2]=0, MUX1[3]=1;
   MUX m1(final, MUX1, selections);
endmodule

module half_adder(sum, carry, y, z);
   input y, z;output sum, carry;
   xor(sum, y, z);
   and(carry, y, z);
endmodule

module full_adder(sum, carry, x, y, z);
   input x, y, z;output sum, carry;
   wire s1, c1, c2;
   half_adder h1(s1, c1, x, y);
   half_adder h2(sum, c2, s1, z);
   or(carry, c1, c2);
endmodule

module D_FlipFlop(output Q, input D);
      assign Q=D;
endmodule

module main();
   parameter N = `NUM_BITS;
   wire [N-1:0] w; wire [N-1:0] e;wire in;wire carry=0;
   if (N==6) begin //6 bits
      assign w[5]=0,w[4]=1,w[3]=0,w[2]=0,w[1]=0,w[0]=0;
      assign e[5]=0,e[4]=0,e[3]=1,e[2]=0,e[1]=0,e[0]=0;
      assign in=w[5];
   end
   if (N==5) begin   // 5 bits
      assign w[4]=1,w[3]=0,w[2]=0,w[1]=0,w[0]=0;
      assign e[4]=0,e[3]=1,e[2]=0,e[1]=0,e[0]=0;
      assign in=w[4];
   end
    if (N==4) begin   // 4 bits
      assign w[3]=0,w[2]=0,w[1]=0,w[0]=0;
      assign e[3]=1,e[2]=0,e[1]=0,e[0]=0;
      assign in=w[3];
   end
    if (N==3) begin   // 3 bits
      assign w[2]=0,w[1]=0,w[0]=1;
      assign e[2]=0,e[1]=1,e[0]=0;
      assign in=w[2];
   end
   if (N==2) begin   // 2 bits
      assign w[1]=0,w[0]=1;
      assign e[1]=1,e[0]=0;
      assign in=w[1];
   end
      if (N==1) begin   // 1 bits
      assign w[0]=1;
      assign e[0]=0;
      assign in=w[0];
   end
   
   //0000 a+b
   wire [N-1:0] o_0; wire [1:0] s_0; wire [1:0] s1_0; wire [N:0]c_0; wire carry0;assign s_0[1]=0, s_0[0]=0, s1_0[1]=0, s1_0[0]=0;wire ci0;
   xor(ci0,s_0[1],s_0[0]);
   quadruple_MUX q0(o_0,carry0,w,e,s1_0,s_0,ci0,in);
   
   //0100 a-b
   wire [N-1:0] o_1; wire [1:0] s_1; wire [1:0] s1_1; wire [N:0]c_1 ;wire carry1;assign s_1[1]=0, s_1[0]=1, s1_1[1]=0, s1_1[0]=0;wire ci1;
   xor(ci1,s_1[1],s_1[0]);
   quadruple_MUX q1(o_1,carry1,w,e,s1_1,s_1,ci1,in);
   
   //1000 a+1
   wire [N-1:0] o_2; wire [1:0] s_2; wire [1:0] s1_2; wire [N:0]c_2;wire carry2;assign s_2[1]=1, s_2[0]=0, s1_2[1]=0, s1_2[0]=0;wire ci2;
   xor(ci2,s_2[1],s_2[0]);
   quadruple_MUX q2(o_2,carry2,w,e,s1_2,s_2,ci2,in);
  
  //1100 a-1
   wire [N-1:0] o_3; wire [1:0] s_3; wire [1:0] s1_3; wire [N:0]c_3;wire carry3;assign s_3[1]=1, s_3[0]=1, s1_3[1]=0, s1_3[0]=0;wire ci3;
   xor(ci3,s_3[1],s_3[0]);
   quadruple_MUX q3(o_3,carry3,w,e,s1_3,s_3,ci3,in);
   
   //0001 a and b 
   wire [N-1:0] o_4; wire [1:0] s_4; wire [1:0] s1_4; wire [N:0]c_4;wire carry4;assign s_4[1]=0, s_4[0]=0, s1_4[1]=0, s1_4[0]=1;wire ci4;
   xor(ci4,s_4[1],s_4[0]);
   quadruple_MUX q4(o_4,carry4,w,e,s1_4,s_4,ci4,in);
   
   //0101 a or b
   wire [N-1:0] o_5; wire [1:0] s_5; wire [1:0] s1_5; wire [N:0]c_5;wire carry5;assign s_5[1]=0, s_5[0]=1, s1_5[1]=0, s1_5[0]=1;wire ci5;
   xor(ci5,s_5[1],s_5[0]);
   quadruple_MUX q5(o_5,carry5,w,e,s1_5,s_5,ci5,in);
   
   //1001 a xor b
   wire [N-1:0] o_6; wire [1:0] s_6; wire [1:0] s1_6; wire [N:0]c_6;wire carry6;assign s_6[1]=1, s_6[0]=0, s1_6[1]=0, s1_6[0]=1;wire ci6;
   xor(ci6,s_6[1],s_6[0]);
   quadruple_MUX q6(o_6,carry6,w,e,s1_6,s_6,ci6,in);
   
   //0010 shift right
   wire [N-1:0] o_7; wire [1:0] s_7; wire [1:0] s1_7; wire [N:0]c_7;wire carry7;assign s_7[1]=0, s_7[0]=0, s1_7[1]=1, s1_7[0]=0;wire ci7;
   xor(ci7,s_7[1],s_7[0]);
   quadruple_MUX q7(o_7,carry7,w,e,s1_7,s_7,ci7, in);
   initial
   begin
 
      $monitor("Adding Two numbers:","\ncarry= %b  Output= %b \n\n",carry0, o_0
      ,"Subtracting Two numbers: \ncarry= %b  Output= %b\n\n",carry1, o_1
      ,"Adding one: \ncarry= %b  Output= %b\n\n",carry2, o_2
      ,"Subtracting one: \ncarry= %b   Output= %b\n\n",carry3, o_3
      ,"Bitwise ANDing for two numbers: \ncarry= %b  Output= %b\n\n",carry, o_4
      ,"Bitwise ORing for two numbers: \ncarry= %b   Output= %b\n\n",carry, o_5
      ,"Bitwise XORing for two numbers: \ncarry= %b  Output= %b\n\n",carry, o_6
      ,"Arithmetic shifting righting: \ncarry= %b   Output= %b\n\n",carry, o_7);
   end
   endmodule

