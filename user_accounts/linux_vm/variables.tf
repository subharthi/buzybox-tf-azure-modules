

variable "user_list" {
    type = list(object({
     username = string
     boxname = string
     outpath = string 
    }))
}


variable "hostname" {
    type = string
}
