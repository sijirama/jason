import { User } from "@/types";

const style = 'open-peeps';
//const style = "lorelei"

export function avatarImageUrl(profile: User): string {
	return `https://api.dicebear.com/8.x/${style}/png?seed=${profile.username}`;
}
