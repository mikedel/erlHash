-module(hashTable).

%% Author: Michael Del Signore
%% Notes: 
%% Number of Buckets is 10

%% ====================================================================
%% API functions
%% ====================================================================
-export([main/0]).
-compile(export_all). 



%% ====================================================================
%% Internal functions
%% ====================================================================
main() ->
	io:format("Welcome to Erlang Hash~n"),
	io:format("The following commands are allowed:~n   addIfAbsent <value>~n   removeIfPresent <value>~n   lookup <value>~n"),
	HashThread = spawn(hashTable, hash, []),%would have used spawn_link here but the assignment said to use spawn
	getCommand(HashThread).

getCommand(HashThread) ->
	{ok, [Command, String]} = io:fread("Please enter an operation in the form <command> <value>: ", "~s~s"),
	HashThread ! {self(), {Command, String}},
	receive
		{true} ->
			io:fwrite("true~n");
		{false} ->
			io:fwrite("false~n")
	end,
	{ok, [Repeat]} = io:fread("Would you like to continue (y/n)?: ", "~s"),
	case Repeat of
		"y" -> getCommand(HashThread);
		"Y" -> getCommand(HashThread);
		"yes" -> getCommand(HashThread);
		"Yes" -> getCommand(HashThread);
		_ -> io:format("Goodbye!~n"),
			 halt()
	end.

hash() ->
	HashTable = lists:duplicate(10, []),
	hashHelper(HashTable).

hashHelper(HashTable) ->
	receive
		{Sender, {Command, String}} ->
			ValidCommand = lists:member(Command, ["addIfAbsent", "removeIfPresent", "lookup"]),
			if
				ValidCommand =:= true ->
					case Command of
						"addIfAbsent" -> {NewHashTable, Result} = add(HashTable, String);
						"removeIfPresent" -> {NewHashTable, Result} = remove(HashTable, String);
						"lookup" -> {NewHashTable, Result} = contains(HashTable, String)				
					end,
					Sender ! {Result};
				true -> io:format("The command was not acceptable~n"),
						NewHashTable = HashTable,
						Sender ! {false}
			end
	end,
	hashHelper(NewHashTable).

add(HashTable, String) ->
	BucketNum = hashFunction(String),
	{Front, Tail} = lists:split(BucketNum - 1, HashTable),
	[Bucket|Rest] = Tail,
	Contains = lists:member(String, Bucket),
	if
		 Contains =:= false ->
			NewBucket = lists:append([Bucket, [String]]),
			NewTail = [NewBucket|Rest],
			NewHashTable = lists:append([Front, NewTail]),
			{NewHashTable, true};
		true -> {HashTable, false}
	end.
	
remove(HashTable, String) ->
	BucketNum = hashFunction(String),
	{Front, Tail} = lists:split(BucketNum - 1, HashTable),
	[Bucket|Rest] = Tail,
	Contains = lists:member(String, Bucket),
	if
		 Contains =:= true ->
			NewBucket = lists:delete(String, Bucket),
			NewTail = [NewBucket|Rest],
			NewHashTable = lists:append([Front, NewTail]),
			{NewHashTable, true};
		true -> {HashTable, false}
	end.

contains(HashTable, String) ->
	BucketNum = hashFunction(String),
	{_, Tail} = lists:split(BucketNum - 1, HashTable),
	[Bucket|_] = Tail,
	Result = lists:member(String, Bucket),
	{HashTable, Result}.

hashFunction(String) ->
	Total = hashFunctionHelper(String),
	Temp = Total rem 10,
	Temp - 1.

hashFunctionHelper(String) -> 
	if
		String == [] -> 0;
		true ->	[Char|Tail] = String,
				Rest = hashFunction(Tail),
				Char + Rest
	end.
	
	
		
	


