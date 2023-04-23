#!/bin/bash

clear;


function something {
	echo "called with $1";

	return 1;
}


if something "TEST"; then
	echo "something returned true";
else
	echo "something returned false";
fi

