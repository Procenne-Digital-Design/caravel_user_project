// SPDX-FileCopyrightText: 2021 Harrison Pham
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

module ringosc_macro #(
  parameter TRIM_BITS = 26
) (
`ifdef USE_POWER_PINS
    inout vccd1,
    inout vssd1,
`endif
    input rst_i,
    input [TRIM_BITS-1:0] trim_fast,
    input [TRIM_BITS-1:0] trim_slow,
    output trng_o
);

wire [1:0] clockp, clockn;
wire [1:0] temp;
wire [1:0] entropy_next;
reg  [1:0] entropy_reg;
wire trng_o;

genvar i;
generate
    for (i = 0; i < 2; i = i + 1) begin : rings
        ring_osc2x13 trng_ring_fast (
            .reset(rst_i),
            .trim(trim_fast),
            .clockp({temp[i],entropy_next[i]})
        );

        ring_osc2x13 trng_ring_slow (
            .reset(rst_i), 
            .trim(trim_slow),
            .clockp({clockn[i],clockp[i]})
        );

        always @(posedge clockp[i])
        begin
            if (rst_i == 1'b1) begin
                entropy_reg[i] <= 1'b0;
            end 
            else begin
                entropy_reg[i] <= entropy_next[i];
            end
        end
    end
endgenerate

assign trng_o = entropy_reg[0] ^ entropy_reg[1];

endmodule
