module clz(
    input [31:0] in,
    output [4:0] out,
    output zero
);
    
    reg [15:0] val16;
    reg [7:0] val8;
    reg [3:0] val4;
    reg [1:0] val2;
    reg [4:0] clz;

    always @(*) begin
        if (|in[31:16]) begin clz[4]=0; val16=in[31:16]; end
        else            begin clz[4]=1; val16=in[15:0]; end

        if (|val16[15:8]) begin clz[3]=0; val8=val16[15:8]; end
        else            begin clz[3]=1; val8=val16[7:0]; end

        if (|val8[7:4]) begin clz[2]=0; val4=val8[7:4]; end
        else            begin clz[2]=1; val4=val8[3:0]; end

        if (|val4[3:2]) begin clz[1]=0; val2=val4[3:2]; end
        else            begin clz[1]=1; val2=val4[1:0]; end

        clz[0] = ~val2[1];
    end

    assign out = clz;
    assign zero = (in == 32'd0);    

endmodule