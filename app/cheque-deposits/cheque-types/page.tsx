import { redirect } from 'next/navigation';

/** External cheque types are managed in the Admin Centre → Setup Pool → FOSA. */
export default function ChequeTypesRedirect() {
  redirect('/admin/pool/fosa/external-cheque-types');
}
