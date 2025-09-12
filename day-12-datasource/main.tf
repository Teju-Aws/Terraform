data "aws_vpc" "name"{
    filter{
        name= "tag:Name"
        values=["tej-vpc"]
    }
}
data "aws_subnet" "name"{
    filter{
        name="tags:Name"
        values=["pub-sub-1"]
    }
}
data "aws_availability_zones"  "name"{
    filter{
        region="ap-south-1"
        values=["Pub-sub-1"]
    }
}