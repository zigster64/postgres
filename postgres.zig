const std = @import("std");
const pq = @cImport({
    @cInclude("libpq-fe.h");
});

pub const version = "0.0.1";

pub const string = []const u8;
pub const c_string = [*:0]const u8;

pub const ConnectionParams = struct {
    hostname: string = "localhost",
    username: string = "postgres",
    dbname: string = "",
    pub fn dsn(self: *ConnectionParams) !c_string {
        const value = try std.fmt.allocPrint0(
            std.heap.page_allocator,
            "host={} dbname={} user={} connect_timeout=10",
            .{ self.hostname, self.dbname, self.username },
        );
        return value;
    }
};

pub const ExecStatusType = enum(u8) {
    PGRES_EMPTY_QUERY = pq.PGRES_EMPTY_QUERY,
    PGRES_COMMAND_OK = pq.PGRES_COMMAND_OK,
    PGRES_TUPLES_OK = pq.PGRES_TUPLES_OK,
    PGRES_COPY_OUT = pq.PGRES_COPY_OUT,
    PGRES_COPY_IN = pq.PGRES_COPY_IN,
    PGRES_BAD_RESPONSE = pq.PGRES_BAD_RESPONSE,
    PGRES_NONFATAL_ERROR = pq.PGRES_NONFATAL_ERROR,
    PGRES_FATAL_ERROR = pq.PGRES_FATAL_ERROR,
    PGRES_COPY_BOTH = pq.PGRES_COPY_BOTH,
    PGRES_SINGLE_TUPLE = pq.PGRES_SINGLE_TUPLE,
};

pub const result = opaque {
    extern fn PQresultStatus(PGresult: *result) u8;
    pub fn status(res: *result) ExecStatusType {
        return @intToEnum(ExecStatusType, PQresultStatus(res));
    }

    extern fn PQcmdStatus(PGresult: *result) c_string;
    pub fn cmdStatus(res: *result) c_string {
        return PQcmdStatus(res);
    }

    extern fn PQcmdTuples(PGresult: *result) c_string;
    pub fn cmdTuples(res: *result) c_string {
        return PQcmdTuples(res);
    }

    extern fn PQclear(PGresult: *result) void;
    pub fn clear(res: *result) void {
        PQclear(res);
    }

    extern fn PQntuples(PGresult: *result) u8;
    pub fn numTuples(res: *result) u8 {
        return PQntuples(res);
    }

    extern fn PQnfields(PGresult: *result) u8;
    pub fn numFields(res: *result) u8 {
        return PQnfields(res);
    }

    extern fn PQfname(PGresult: *result, fld: u8) c_string;
    pub fn fieldName(res: *result, fld: u8) c_string {
        return PQfname(res, fld);
    }

    extern fn PQfnumber(PGresult: *result, fld: c_string) u8;
    pub fn fieldNumber(res: *result, fld: c_string) u8 {
        return PQfnumber(res, fld);
    }

    extern fn PQgetvalue(PGresult: *result, row: u8, col: u8) c_string;
    pub fn get(res: *result, row: u8, col: u8) c_string {
        return PQgetvalue(res, row, col);
    }

    //int PQgetisnull(const PGresult *res,
    //int row_number,
    //int column_number);
};

pub const DB = opaque {
    extern fn PQexec(PGconn: *DB, command: c_string) *result;
    pub fn exec(conn: *DB, command: c_string) *result {
        return PQexec(conn, @ptrCast(c_string, command));
    }

    extern fn PQdb(PGconn: *DB) c_string;
    pub fn name(conn: *DB) c_string {
        return PQdb(conn);
    }
};

extern fn PQconnectdb(dsn: c_string) *DB;
pub fn connect(dsn: c_string) ?*DB {
    var conn = PQconnectdb(dsn);
    return conn;
}
