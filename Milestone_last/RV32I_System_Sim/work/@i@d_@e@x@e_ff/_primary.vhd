library verilog;
use verilog.vl_types.all;
entity ID_EXE_ff is
    port(
        clk             : in     vl_logic;
        IF_ID_pc        : in     vl_logic_vector(31 downto 0);
        funct3          : in     vl_logic_vector(2 downto 0);
        rd              : in     vl_logic_vector(4 downto 0);
        rs1             : in     vl_logic_vector(4 downto 0);
        rs2             : in     vl_logic_vector(4 downto 0);
        MEM_WB_rd       : in     vl_logic_vector(4 downto 0);
        rd_data         : in     vl_logic_vector(31 downto 0);
        rs1_data        : in     vl_logic_vector(31 downto 0);
        rs2_data        : in     vl_logic_vector(31 downto 0);
        se_imm_itype    : in     vl_logic_vector(31 downto 0);
        se_imm_stype    : in     vl_logic_vector(31 downto 0);
        auipc_lui_imm   : in     vl_logic_vector(31 downto 0);
        se_br_imm       : in     vl_logic_vector(31 downto 0);
        se_jal_imm      : in     vl_logic_vector(31 downto 0);
        MEM_WB_regwrite : in     vl_logic;
        ID_EXE_pc       : out    vl_logic_vector(31 downto 0);
        ID_EXE_funct3   : out    vl_logic_vector(2 downto 0);
        ID_EXE_rd       : out    vl_logic_vector(4 downto 0);
        ID_EXE_rs1      : out    vl_logic_vector(4 downto 0);
        ID_EXE_rs2      : out    vl_logic_vector(4 downto 0);
        ID_EXE_rs1_data : out    vl_logic_vector(31 downto 0);
        ID_EXE_rs2_data : out    vl_logic_vector(31 downto 0);
        ID_EXE_se_imm_itype: out    vl_logic_vector(31 downto 0);
        ID_EXE_se_imm_stype: out    vl_logic_vector(31 downto 0);
        ID_EXE_se_auipc_lui_imm: out    vl_logic_vector(31 downto 0);
        ID_EXE_se_br_imm: out    vl_logic_vector(31 downto 0);
        ID_EXE_se_jal_imm: out    vl_logic_vector(31 downto 0)
    );
end ID_EXE_ff;
